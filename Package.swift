// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "FloatingWindow",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "FloatingWindow",
            targets: ["FloatingWindow"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "FloatingWindow",
            dependencies: [],
            path: "Sources/FloatingWindow",
            resources: []
        )
    ]
)
