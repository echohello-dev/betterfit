// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BetterFit",
    platforms: [
        .iOS(.v17),
        .watchOS(.v10),
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "BetterFit",
            targets: ["BetterFit"])
    ],
    dependencies: [
        .package(url: "https://github.com/supabase/supabase-swift.git", from: "2.39.0")
    ],
    targets: [
        .target(
            name: "BetterFit",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
                .product(name: "Auth", package: "supabase-swift"),
                .product(name: "PostgREST", package: "supabase-swift"),
            ]),
        .testTarget(
            name: "BetterFitTests",
            dependencies: ["BetterFit"]),
    ]
)
