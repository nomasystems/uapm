// Copyright 2023 Nomasystems S.L.

import Foundation

enum ArchiveFormat {
    case tar
    case zip

    static func recognize(_ url: URL) -> ArchiveFormat? {
        let name = url.lastPathComponent.lowercased()
        let ext = (name as NSString).pathExtension

        if ext == "tar" || ((name as NSString).deletingPathExtension as NSString).pathExtension == "tar" {
            return .tar
        } else if ext == "zip" {
            return .zip
        }

        return nil
    }

    func extractionCommand(
        archive: URL,
        destination: URL
    ) -> (command: String, arguments: [String]) {
        switch self {
        case .tar:
            (
                command: "/usr/bin/tar",
                arguments: ["-C", destination.path, "-xf", archive.path]
            )
        case .zip:
            (
                command: "/usr/bin/unzip",
                arguments: [archive.path, "-d", destination.path]
            )
        }
    }
}
