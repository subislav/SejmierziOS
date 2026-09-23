// swift-tools-version: 5.9

import PackageDescription

enum TargetName: String {
    case appFeature = "AppFeature"
    case domain = "Domain"
    case data = "Data"
    case ui = "UI"
}

let package = Package(
    name: "Sejmierz",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .singleTargetLibrary(.domain),
        .singleTargetLibrary(.data),
        .singleTargetLibrary(.ui),
        .singleTargetLibrary(.appFeature)
    ],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.24.0")
    ],
    targets: [
        .singleModuleTarget(
            name: .appFeature,
            dependencies: [
                .target(.ui),
                .target(.data),
                .target(.domain)
            ]
        ),
        .singleModuleTarget(
            name: .domain
        ),
        .singleModuleTarget(
            name: .data,
            dependencies: [
                .target(.domain),
                .product(name: "GRDB", package: "GRDB.swift")
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .singleModuleTarget(
            name: .ui,
            dependencies: [
                .target(.domain)
            ]
        )
    ]
)

extension Target.Dependency {
    static func target(_ name: TargetName) -> Target.Dependency {
        .target(name: name.rawValue)
    }
}

extension Target {
    static func singleModuleTarget(
        name targetName: TargetName,
        dependencies: [Dependency] = [],
        path: String? = nil,
        resources: [Resource]? = nil
    ) -> Target {
        .target(
            name: targetName.rawValue,
            dependencies: dependencies,
            path: path ?? targetName.rawValue,
            resources: resources,
            swiftSettings: [
                .unsafeFlags([
                    "-enable-bare-slash-regex"
                ])
            ]
        )
    }
}

extension Product {
    static func singleTargetLibrary(_ name: TargetName) -> PackageDescription.Product {
        .library(
            name: name.rawValue,
            targets: [
                name.rawValue
            ]
        )
    }
}
