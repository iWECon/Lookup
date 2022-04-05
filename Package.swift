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
    dependencies: [
        .package(url: "https://github.com/Quick/Quick.git", from: "4.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "9.0.0")
    ],
    targets: [
        .target(name: "Lookup", dependencies: []),
<<<<<<< Updated upstream
        .testTarget(name: "LookupTests", dependencies: ["Lookup"])
    ]
=======
        .testTarget(
            name: "LookupTests",
            dependencies: [
                "Lookup",
                "Quick", "Nimble"
            ])
    ],
    swiftLanguageVersions: [.v5]
>>>>>>> Stashed changes
)
