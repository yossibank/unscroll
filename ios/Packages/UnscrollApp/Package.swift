// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "UnscrollApp",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "AppFeature",
            targets: ["AppFeature"]
        )
    ],
    dependencies: [
        .package(path: "../UnscrollKit")
    ],
    targets: [
        .target(
            name: "AppFeature",
            dependencies: [
                "DesignSystem",
                "Features",
                .product(name: "Core", package: "UnscrollKit"),
                .product(name: "Store", package: "UnscrollKit")
            ]
        ),
        .target(
            name: "Features",
            dependencies: [
                "DesignSystem",
                .product(name: "Core", package: "UnscrollKit"),
                .product(name: "Store", package: "UnscrollKit")
            ]
        ),
        .target(
            name: "DesignSystem",
            dependencies: [
                .product(name: "Core", package: "UnscrollKit")
            ]
        ),
        .testTarget(
            name: "AppFeatureTests",
            dependencies: ["AppFeature"]
        ),
        .testTarget(
            name: "DesignSystemTests",
            dependencies: ["DesignSystem"]
        ),
        .testTarget(
            name: "FeaturesTests",
            dependencies: ["Features"]
        )
    ]
)
