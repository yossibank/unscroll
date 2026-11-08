// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MilmoApp",
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
        .package(path: "../MilmoKit")
    ],
    targets: [
        .target(
            name: "AppFeature",
            dependencies: [
                "DesignSystem",
                "Features",
                .product(name: "Core", package: "MilmoKit"),
                .product(name: "Store", package: "MilmoKit")
            ]
        ),
        .target(
            name: "Features",
            dependencies: [
                "DesignSystem",
                .product(name: "Core", package: "MilmoKit"),
                .product(name: "Store", package: "MilmoKit")
            ]
        ),
        .target(
            name: "DesignSystem",
            dependencies: [
                .product(name: "Core", package: "MilmoKit")
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
