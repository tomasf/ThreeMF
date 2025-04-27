// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ThreeMF",
    platforms: [.macOS(.v10_15), .iOS(.v13)],
    products: [
        .library(name: "ThreeMF", targets: ["ThreeMF"])
    ],
    dependencies: [
        .package(url: "https://github.com/tomasf/Zip.git", from: "2.0.0"),
        .package(url: "https://github.com/tomasf/Nodal.git", from: "0.3.1")
    ],
    targets: [
        .target(
            name: "ThreeMF",
            dependencies: ["Zip", "Nodal"],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        )
    ]
)
