// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "swiped",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/Kyome22/OpenMultitouchSupport.git", exact: "3.0.3"),
        .package(url: "https://github.com/LebJe/TOMLKit.git", from: "0.6.0"),
    ],
    targets: [
        .executableTarget(
            name: "swiped",
            dependencies: [
                .product(name: "OpenMultitouchSupport", package: "OpenMultitouchSupport"),
                .product(name: "TOMLKit", package: "TOMLKit"),
            ]
        ),
    ]
)
