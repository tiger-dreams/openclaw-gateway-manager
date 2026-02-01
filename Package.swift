// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "OpenClawManager",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "OpenClawManager",
            targets: ["OpenClawManager"]
        )
    ],
    dependencies: [
    ],
    targets: [
        .executableTarget(
            name: "OpenClawManager",
            dependencies: [],
            resources: [
                .copy("Resources/AppIcon.appiconset"),
                .copy("Resources/AppIcon.icns")
            ]
        )
    ]
)
