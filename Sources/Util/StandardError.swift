// Copyright 2023 Nomasystems S.L.

import Foundation

public var standardError = StandardError()

public final class StandardError: TextOutputStream {
    public func write(_ string: String) {
        try! FileHandle.standardError.write(contentsOf: Data(string.utf8))
    }
}
