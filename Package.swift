// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "uapm",
    platforms: [
        .macOS(.v12),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.1"),
    ],
    targets: [
        .executableTarget(
            name: "uapm",
            dependencies: [
                .target(name: "UapmLib"),
                .target(name: "Util"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .target(
            name: "UapmLib",
            dependencies: [
                .target(name: "Util"),
            ]
        ),
        .target(name: "Util"),
    ]
)
