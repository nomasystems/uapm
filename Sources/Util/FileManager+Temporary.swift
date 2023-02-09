// Copyright 2023 Nomasystems S.L.

import Foundation

public extension FileManager {
    func withTemporaryDirectory<Result>(
        body: (URL) async throws -> Result
    ) async throws
        -> Result
    {
        let url = try url(
            for: .itemReplacementDirectory,
            in: .userDomainMask,
            appropriateFor: temporaryDirectory,
            create: true
        )
        defer {
            try? removeItem(at: url)
        }

        return try await body(url)
    }
}
