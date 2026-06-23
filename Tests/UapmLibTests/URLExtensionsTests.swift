// Copyright 2023 Nomasystems S.L.

import Foundation
import Testing

@testable import UapmLib

@Suite
struct URLExtensionsTests {
    @Test func returnsFinalExtensionForSimpleFilename() {
        let url = URL(string: "https://example.com/tool.zip")!
        #expect(url.recognizedPathExtension == "zip")
    }

    @Test(arguments: URL.knownCompoundPathExtensions)
    func returnsKnownCompoundExtension(ext: String) {
        let url = URL(string: "https://example.com/tool.\(ext)")!
        #expect(url.recognizedPathExtension == ext)
    }

    @Test func ignoresVersionNumbersInFilename() {
        let url = URL(string: "https://example.com/tool-1.8.0.zip")!
        #expect(url.recognizedPathExtension == "zip")
    }

    @Test(arguments: URL.knownCompoundPathExtensions)
    func returnsKnownCompoundExtensionAfterVersionNumber(ext: String) {
        let url = URL(string: "https://example.com/tool-2.1.0.\(ext)")!
        #expect(url.recognizedPathExtension == ext)
    }

    @Test func returnsEmptyStringWhenFilenameHasNoExtension() {
        let url = URL(string: "https://example.com/tool")!
        #expect(url.recognizedPathExtension == "")
    }

    @Test func unknownCompoundExtensionFallsBackToFinalExtension() {
        let url = URL(string: "https://example.com/tool-1.8.0.foo.bar")!
        #expect(url.recognizedPathExtension == "bar")
    }

    @Test(arguments: URL.knownCompoundPathExtensions)
    func uppercaseCompoundExtension(ext: String) {
        let url = URL(string: "https://example.com/tool.\(ext.uppercased())")!
        #expect(url.recognizedPathExtension == ext)
    }

    @Test(arguments: URL.knownCompoundPathExtensions)
    func compoundExtensionWithQueryItems(ext: String) {
        let url = URL(string: "https://example.com/tool.\(ext)?download=true")!
        #expect(url.recognizedPathExtension == ext)
    }

}
