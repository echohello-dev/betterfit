// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BetterFit",
    platforms: [
        .iOS(.v17),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "BetterFit",
            targets: ["BetterFit"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "BetterFit",
            dependencies: []),
        .testTarget(
            name: "BetterFitTests",
            dependencies: ["BetterFit"]),
    ]
)
