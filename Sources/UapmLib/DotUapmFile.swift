// Copyright 2023 Nomasystems S.L.

import Foundation

public struct DotUapm {
    public let packages: [UapmPackage]
}

public extension DotUapm {
    init(data: Data) throws {
        packages = try JSONDecoder().decode([UapmPackage].self, from: data)
    }
}
