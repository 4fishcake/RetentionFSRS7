// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "RetentionFSRS7",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "RetentionFSRS7",
            targets: ["RetentionFSRS7"]
        )
    ],
    targets: [
        .target(
            name: "RetentionFSRS7"
        ),
        .testTarget(
            name: "RetentionFSRS7Tests",
            dependencies: ["RetentionFSRS7"]
        )
    ]
)
