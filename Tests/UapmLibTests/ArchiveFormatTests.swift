// Copyright 2023 Nomasystems S.L.

import Foundation
import Testing

@testable import UapmLib

@Suite
struct ArchiveFormatTests {
    @Test(arguments: [
        ("tool.zip", ArchiveFormat?.some(.zip)),
        ("tool.tar", ArchiveFormat?.some(.tar)),
        ("tool.tar.gz", ArchiveFormat?.some(.tar)),
        ("tool.tar.foobar", ArchiveFormat?.some(.tar)),
        ("tool-1.0.0.zip", ArchiveFormat?.some(.zip)),
        ("tool-1.0.0.tar.gz", ArchiveFormat?.some(.tar)),
        ("tool.TAR.GZ", ArchiveFormat?.some(.tar)),
        ("tool.foo.bar", ArchiveFormat?.none),
        ("tool", ArchiveFormat?.none),
    ])
    func recognize(path: String, expected: ArchiveFormat?) {
        let url = URL(string: "https://example.com/\(path)")!
        #expect(ArchiveFormat.recognize(url) == expected)
    }
}
