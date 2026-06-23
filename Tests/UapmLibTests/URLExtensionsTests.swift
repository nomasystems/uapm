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

    @Test func returnsKnownCompoundExtension() {
        let url = URL(string: "https://example.com/tool.tar.gz")!
        #expect(url.recognizedPathExtension == "tar.gz")
    }

    @Test func ignoresVersionNumbersInFilename() {
        let url = URL(string: "https://example.com/ktlint-1.8.0.zip")!
        #expect(url.recognizedPathExtension == "zip")
    }

    @Test func returnsKnownCompoundExtensionAfterVersionNumber() {
        let url = URL(string: "https://example.com/tool-2.1.0.tar.gz")!
        #expect(url.recognizedPathExtension == "tar.gz")
    }

    @Test func returnsEmptyStringWhenFilenameHasNoExtension() {
        let url = URL(string: "https://example.com/tool")!
        #expect(url.recognizedPathExtension == "")
    }

    @Test func unknownCompoundExtensionFallsBackToFinalExtension() {
        let url = URL(string: "https://example.com/file.foo.bar")!
        #expect(url.recognizedPathExtension == "bar")
    }

    @Test func uppercaseTarGzExtension() {
        let url = URL(string: "https://example.com/tool.TAR.GZ")!
        #expect(url.recognizedPathExtension == "tar.gz")
    }

    @Test func extensionWithQueryItems() {
        let url = URL(string: "https://example.com/tool.tar.gz?download=true")!
        #expect(url.recognizedPathExtension == "tar.gz")
    }

    @Test func versionedUnknownCompoundExtension() {
        let url = URL(string: "https://example.com/tool-1.8.0.foo.bar")!
        #expect(url.recognizedPathExtension == "bar")
    }
}
