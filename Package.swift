// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Lookup",
    platforms: [
        .iOS(.v9),
        .macOS(.v11)
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
