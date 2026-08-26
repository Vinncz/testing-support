// swift-tools-version: 6.2.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TestingSupport",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(
            name: "TestingSupport",
            targets: ["TestingSupport"]
        ),
    ],
    targets: [
        .target(
            name: "TestingSupport"
        ),
        .testTarget(
            name: "TestingSupportTests",
            dependencies: ["TestingSupport"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
