// Copyright 2023 Nomasystems S.L.

import Foundation

extension URL {
    private static let knownCompoundPathExtensions: Set<String> = [
        "tar.gz",
        "tar.bz2",
        "tar.xz",
        "tar.zst",
    ]

    var recognizedPathExtension: String {
        let filename = lastPathComponent.lowercased()

        if let compoundExtension = Self.knownCompoundPathExtensions.first(where: {
            filename.hasSuffix(".\($0)")
        }) {
            return compoundExtension
        }

        return pathExtension.lowercased()
    }
}
