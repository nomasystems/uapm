// Copyright 2023 Nomasystems S.L.

import Foundation

public struct UapmPackage {
    let name: String
    let version: String
    let url: URL
    let checksum: String
    let archiveExecutablePath: String

    public init(
        name: String,
        version: String,
        url: URL,
        checksum: String,
        archiveExecutablePath: String
    ) {
        self.name = name
        self.version = version
        self.url = url
        self.checksum = checksum
        self.archiveExecutablePath = archiveExecutablePath
    }
}

extension UapmPackage: Decodable {}
