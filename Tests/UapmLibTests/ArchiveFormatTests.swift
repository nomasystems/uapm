// Copyright 2023 Nomasystems S.L.

import Foundation
import Testing

@testable import UapmLib

@Suite
struct ArchiveFormatTests {
    @Test func recognizesZip() {
        let url = URL(string: "https://example.com/tool.zip")!
        #expect(ArchiveFormat.recognize(url) == .zip)
    }

    @Test(arguments: ["tar.gz", "tar.bz2", "tar.xz", "tar.zst"])
    func recognizesTarVariants(ext: String) {
        let url = URL(string: "https://example.com/tool.\(ext)")!
        #expect(ArchiveFormat.recognize(url) == .tar)
    }

    @Test func recognizesPlainTar() {
        let url = URL(string: "https://example.com/tool.tar")!
        #expect(ArchiveFormat.recognize(url) == .tar)
    }

    @Test func returnsNilForUnknownExtension() {
        let url = URL(string: "https://example.com/tool.dmg")!
        #expect(ArchiveFormat.recognize(url) == nil)
    }

    @Test func returnsNilForNoExtension() {
        let url = URL(string: "https://example.com/tool")!
        #expect(ArchiveFormat.recognize(url) == nil)
    }

    @Test func ignoresVersionNumbersInFilename() {
        let url = URL(string: "https://example.com/tool-1.8.0.zip")!
        #expect(ArchiveFormat.recognize(url) == .zip)
    }

    @Test(arguments: ["tar.gz", "tar.bz2", "tar.xz", "tar.zst"])
    func recognizesTarVariantsAfterVersionNumber(ext: String) {
        let url = URL(string: "https://example.com/tool-2.1.0.\(ext)")!
        #expect(ArchiveFormat.recognize(url) == .tar)
    }

    @Test func uppercaseExtension() {
        let url = URL(string: "https://example.com/tool.TAR.GZ")!
        #expect(ArchiveFormat.recognize(url) == .tar)
    }

    @Test func extensionWithQueryItems() {
        let url = URL(string: "https://example.com/tool.tar.gz?download=true")!
        #expect(ArchiveFormat.recognize(url) == .tar)
    }

    @Test func unknownCompoundExtensionReturnsNil() {
        let url = URL(string: "https://example.com/tool-1.8.0.foo.bar")!
        #expect(ArchiveFormat.recognize(url) == nil)
    }
}
