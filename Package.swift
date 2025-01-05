// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ThreeMF",
    products: [
        .library(name: "ThreeMF", targets: ["ThreeMF"])
    ],
    dependencies: [
        .package(url: "https://github.com/tomasf/Zip.git", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "ThreeMF",
            dependencies: ["Zip"]
        ),
        .testTarget(
            name: "Tests",
            dependencies: ["ThreeMF"],
            resources: [.copy("3MF")]
        )
    ]
)
