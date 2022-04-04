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
    targets: [
        .target(name: "Lookup", dependencies: []),
        .testTarget(name: "LookupTests", dependencies: ["Lookup"])
    ],
    swiftLanguageVersions: [.v5]
)
