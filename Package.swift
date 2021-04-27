// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "TextEdit",
    platforms: [.macOS(.v10_15), .iOS(.v14)],
    products: [
        .library(
            name: "TextEdit",
            targets: ["TextEdit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/krzyzanowskim/CoreTextSwift.git", from: "0.0.1"),
    ],
    targets: [
        .target(
            name: "TextEdit",
            dependencies: ["CoreTextSwift"])
    ]
)
