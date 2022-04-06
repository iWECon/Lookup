// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Lookup",
    platforms: [
        .iOS(.v9),
        .tvOS(.v9),
        .watchOS(.v6),
        .macOS(.v10_10)
    ],
    products: [
        .library(name: "Lookup", targets: ["Lookup"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Quick.git", from: "4.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "9.0.0")
    ],
    targets: [
        .target(name: "Lookup", dependencies: []),
        .testTarget(
            name: "LookupTests",
            dependencies: [
                "Lookup",
                "Quick", "Nimble"
            ])
    ],
    swiftLanguageVersions: [.v5]
)
