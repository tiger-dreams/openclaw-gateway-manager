// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MoltbotManager",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "MoltbotManager",
            targets: ["MoltbotManager"]
        )
    ],
    dependencies: [
    ],
    targets: [
        .executableTarget(
            name: "MoltbotManager",
            dependencies: [],
            resources: [
                .copy("Resources/AppIcon.appiconset"),
                .copy("Resources/AppIcon.icns")
            ]
        )
    ]
)
