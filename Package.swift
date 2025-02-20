// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ThreeMF",
    platforms: [.macOS(.v10_15)],
    products: [
        .library(name: "ThreeMF", targets: ["ThreeMF"])
    ],
    dependencies: [
        .package(url: "https://github.com/tomasf/Zip.git", from: "2.0.0"),
        .package(path: "../Nodal")
    ],
    targets: [
        .target(
            name: "ThreeMF",
            dependencies: ["Zip", "Nodal"],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        ),
        .testTarget(
            name: "Tests",
            dependencies: ["ThreeMF"],
            resources: [.copy("3MF")],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        )
    ]
)
