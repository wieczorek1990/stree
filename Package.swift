// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "stree",
    dependencies: [],
    targets: [
        .executableTarget(
            name: "stree",
            dependencies: []),
        .testTarget(
            name: "streeTests",
            dependencies: ["stree"]),
    ]
)
