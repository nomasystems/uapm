// Copyright 2023 Nomasystems S.L.

import ArgumentParser
import Foundation
import UapmLib
import Util

private let defaultCacheDir = FileManager.default
    .urls(for: .cachesDirectory, in: .userDomainMask)[0]
    .appendingPathComponent("uapm", isDirectory: true)

private let defaultBinDir = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    .appendingPathComponent(".bin")

@main
struct Uapm: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "The μ adhoc package manager.",
        subcommands: [
            Install.self,
            Checksum.self,
        ]
    )
}

extension Uapm {
    struct Install: AsyncParsableCommand {
        static var configuration =
            CommandConfiguration(abstract: "Install packages declared in an uapm packages file.")

        @Argument(help: "Packages file.", transform: URL.init(fileURLWithPath:))
        var packagesDotUapm: URL

        @Option(
            help: "Installation directory. Defaults to .bin in the current working directory.",
            transform: URL.init(fileURLWithPath:)
        )
        var binDir: URL?

        @Option(help: "Download cache directory.", transform: URL.init(fileURLWithPath:))
        var cacheDir: URL?

        mutating func run() async throws {
            do {
                let binDir = binDir ?? defaultBinDir
                let cacheDir = cacheDir ?? defaultCacheDir
                let dotUapm = try DotUapm(data: try Data(contentsOf: packagesDotUapm))
                for package in dotUapm.packages {
                    try await downloadAndInstall(
                        package: package,
                        binDir: binDir,
                        cacheDir: cacheDir
                    )
                }
                print("OK", to: &standardError)
            } catch let error {
                print(error, to: &standardError)
                print("error: failed to install one or more packages", to: &standardError)
                throw ExitCode.failure
            }
        }
    }
}

extension Uapm {
    struct Checksum: AsyncParsableCommand {
        static var configuration
            = CommandConfiguration(abstract: "Download and compute the checksum of an archive.")

        @Argument(
            help: "The archive URL.",
            transform: {
                guard let url = URL(string: $0) else {
                    throw ValidationError("Not a valid url")
                }
                return url
            }
        )
        var url: URL

        mutating func run() async throws {
            do {
                let (fileUrl, _) = try await URLSession.shared.download(from: url)
                print(try checksum(fileUrl: fileUrl))
            } catch let error {
                print(error, to: &standardError)
                throw ExitCode.failure
            }
        }
    }
}
