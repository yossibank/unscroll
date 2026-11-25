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
        ),
        .library(
            name: "DesignSystem",
            targets: ["DesignSystem"]
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
                "FeatureModels",
                "Features",
                .product(name: "Core", package: "UnscrollKit")
            ],
            swiftSettings: [
                .enableUpcomingFeature("MemberImportVisibility")
            ]
        ),
        .target(
            name: "FeatureModels",
            dependencies: [
                "DesignSystem",
                .product(name: "Core", package: "UnscrollKit"),
                .product(name: "Store", package: "UnscrollKit")
            ]
        ),
        .target(
            name: "Features",
            dependencies: [
                "DesignSystem",
                "FeatureModels",
                .product(name: "Core", package: "UnscrollKit")
            ],
            swiftSettings: [
                .enableUpcomingFeature("MemberImportVisibility")
            ]
        ),
        .target(
            name: "DesignSystem",
            dependencies: [
                .product(name: "Core", package: "UnscrollKit")
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "AppFeatureTests",
            dependencies: [
                "AppFeature",
                "FeatureModels",
                .product(name: "Store", package: "UnscrollKit")
            ]
        ),
        .testTarget(
            name: "DesignSystemTests",
            dependencies: ["DesignSystem"]
        ),
        .testTarget(
            name: "FeaturesTests",
            dependencies: [
                "FeatureModels",
                "Features",
                .product(name: "Core", package: "UnscrollKit"),
                .product(name: "Store", package: "UnscrollKit")
            ]
        )
    ]
)
