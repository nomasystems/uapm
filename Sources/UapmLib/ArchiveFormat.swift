// Copyright 2023 Nomasystems S.L.

import Foundation
import Util

enum ArchiveFormat {
    case tar
    case zip

    static func recognize(_ url: URL) -> ArchiveFormat? {
        let fileURL = URL(fileURLWithPath: url.lastPathComponent.lowercased())
        let ext = fileURL.pathExtension

        if ext == "tar" || fileURL.deletingPathExtension().pathExtension == "tar" {
            return .tar
        } else if ext == "zip" {
            return .zip
        }

        return nil
    }

    func fileExtension(from url: URL) -> String {
        let fileURL = URL(fileURLWithPath: url.lastPathComponent.lowercased())
        switch self {
        case .tar:
            let outer = fileURL.pathExtension
            let inner = fileURL.deletingPathExtension().pathExtension
            return inner == "tar" ? "tar.\(outer)" : "tar"
        case .zip:
            return "zip"
        }
    }

    struct ExtractionCommand {
        fileprivate let url: URL
        fileprivate let arguments: [String]
    }

    func extractionCommand(
        archive: URL,
        destination: URL
    ) -> ExtractionCommand {
        switch self {
        case .tar:
            ExtractionCommand(
                url: URL(fileURLWithPath: "/usr/bin/tar"),
                arguments: ["-C", destination.path, "-xf", archive.path]
            )
        case .zip:
            ExtractionCommand(
                url: URL(fileURLWithPath: "/usr/bin/unzip"),
                arguments: [archive.path, "-d", destination.path]
            )
        }
    }
}

extension Process {
    static func runAndOutputError(_ command: ArchiveFormat.ExtractionCommand) async throws {
        try await runAndOutputError(url: command.url, arguments: command.arguments)
    }
}
