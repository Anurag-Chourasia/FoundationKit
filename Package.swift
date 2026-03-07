// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FoundationKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "FoundationKit",
            targets: ["FoundationKit"]
        )
    ],
    targets: [
        .target(
            name: "FoundationKit"
        ),
        .testTarget(
            name: "FoundationKitTests",
            dependencies: ["FoundationKit"]
        )
    ]
)
