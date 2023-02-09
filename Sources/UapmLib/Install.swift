// Copyright 2023 Nomasystems S.L.

import CryptoKit
import Foundation
import UniformTypeIdentifiers
import Util

enum DownloadError: Error {
    case checksumError
    case unrecognizedArchiveType(String)
}

public func downloadAndInstall(
    package: UapmPackage,
    binDir: URL,
    cacheDir: URL?
) async throws {
    let executableSubpath = "\(package.nameVersion)/\(package.name)"
    let symbolicLinkUrl = binDir.appendingPathComponent(package.name)
    let executableDestUrl = binDir.appendingPathComponent(executableSubpath)
    if let exists = try? executableDestUrl.checkResourceIsReachable(), exists {
        try FileManager.default.safeCreateSymbolicLink(
            at: symbolicLinkUrl,
            withDestinationURL: executableDestUrl
        )
        print("\(package.nameVersion) is already installed, skipping.", to: &standardError)
        return
    }
    try FileManager.default.createDirectory(
        at: executableDestUrl.deletingLastPathComponent(),
        withIntermediateDirectories: true
    )

    try await download(package: package, cacheDir: cacheDir) { downloadedExecutableUrl in
        try FileManager.default.moveItem(at: downloadedExecutableUrl, to: executableDestUrl)
        try FileManager.default.safeCreateSymbolicLink(
            at: symbolicLinkUrl,
            withDestinationURL: executableDestUrl
        )
        print("Installed \(package.nameVersion).")
    }
}

public func checksum(
    fileUrl: URL
) throws
    -> String
{
    let digest = SHA256.hash(data: try Data(contentsOf: fileUrl))
    return digest.hexadecimalString
}

private func download(
    package: UapmPackage,
    cacheDir: URL?,
    _ body: (_ executableUrl: URL) throws -> Void
) async throws {
    if let cacheDir {
        let cacheFileUrl = cacheFileUrl(package: package, cacheDir: cacheDir)
        if let cacheFileExists = try? cacheFileUrl.checkResourceIsReachable(), cacheFileExists {
            print("Unpacking \(package.nameVersion) from cache ...", to: &standardError)
            return try await unpack(package: package, fileUrl: cacheFileUrl, body)
        }
    }

    print(
        "Downloading \(package.nameVersion) from \(package.url.absoluteString) ...",
        to: &standardError
    )
    let (fileUrl, _) = try await URLSession.shared.download(from: package.url)
    try await unpack(package: package, fileUrl: fileUrl, body)
    if let cacheDir {
        let cacheFileUrl = cacheFileUrl(package: package, cacheDir: cacheDir)
        try? FileManager.default.copyItem(at: fileUrl, to: cacheFileUrl)
    }
}

private func unpack(
    package: UapmPackage,
    fileUrl: URL,
    _ body: (_ executableUrl: URL) throws -> Void
) async throws {
    let checksum = try checksum(fileUrl: fileUrl)
    guard checksum == package.checksum else {
        print(
            "error: checksum mismatch for \(package.url.absoluteString), expected: \(package.checksum), got: \(checksum)",
            to: &standardError
        )
        throw DownloadError.checksumError
    }

    try await FileManager.default.withTemporaryDirectory { tmpDirUrl in
        try await extract(
            fileUrl: fileUrl,
            extractDir: tmpDirUrl,
            pathExtensions: package.url.pathExtensions
        )
        let executableUrl = tmpDirUrl.appendingPathComponent(package.archiveExecutablePath)
        try body(executableUrl)
    }
}

private func extract(fileUrl: URL, extractDir: URL, pathExtensions: String) async throws {
    let commandAndArgument: (String, [String])
    switch pathExtensions {
    case "zip":
        commandAndArgument = ("/usr/bin/unzip", [fileUrl.path, "-d", extractDir.path])
    case "tar.gz":
        commandAndArgument = ("/usr/bin/tar", ["-C", extractDir.path, "-xvf", fileUrl.path])
    default:
        throw DownloadError.unrecognizedArchiveType(fileUrl.pathExtensions)
    }
    try await Process.runAndOutputError(
        url: URL(fileURLWithPath: commandAndArgument.0),
        arguments: commandAndArgument.1
    )
}

private func cacheFileUrl(package: UapmPackage, cacheDir: URL) -> URL {
    let urlSha256 = SHA256.hash(data: Data(package.url.absoluteString.utf8))
    let pathExtensions = package.url.pathExtensions
    let filename =
        "\(package.name)-\(package.version)-\(urlSha256.hexadecimalString).\(pathExtensions)"
    return cacheDir.appendingPathComponent(filename)
}

private extension UapmPackage {
    var nameVersion: String {
        "\(name)-\(version)"
    }
}

private extension FileManager {
    func safeCreateSymbolicLink(at url: URL, withDestinationURL destUrl: URL) throws {
        switch try checkExistingSymbolicLink(at: url, destUrl: destUrl) {
        case .matches:
            break
        case .differentDest:
            try removeItem(at: url)
            fallthrough
        case .none:
            try FileManager.default.createSymbolicLink(at: url, withDestinationURL: destUrl)
        }
    }

    enum ExistingSymbolinkLink {
        case none
        case differentDest
        case matches
    }

    func checkExistingSymbolicLink(at url: URL, destUrl: URL) throws -> ExistingSymbolinkLink {
        if let ok = try? url.checkResourceIsReachable(), ok {
            let symbolicLinkValues = try url.resourceValues(forKeys: [.isSymbolicLinkKey])
            if let isSymbolicLink = symbolicLinkValues.isSymbolicLink, isSymbolicLink {
                let existingDest = url.resolvingSymlinksInPath()
                if existingDest != destUrl {
                    return .differentDest
                } else {
                    return .matches
                }
            }
        }
        return .none
    }
}
