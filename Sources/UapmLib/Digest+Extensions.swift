// Copyright 2023 Nomasystems S.L.

import CryptoKit

extension Digest {
    var hexadecimalString: String {
        withUnsafeBytes { bytes in
            bytes.reduce(into: "") { $0.append(String(format: "%02x", $1)) }
        }
    }
}
