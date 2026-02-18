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
        ),
        .library(
            name: "OpenClawKit",
            targets: ["OpenClawKit"]
        )
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "OpenClawKit",
            dependencies: []
        ),
        .executableTarget(
            name: "OpenClawManager",
            dependencies: ["OpenClawKit"],
            resources: [
                .copy("Resources/AppIcon.appiconset"),
                .copy("Resources/AppIcon.icns")
            ]
        ),
        .testTarget(
            name: "OpenClawManagerTests",
            dependencies: ["OpenClawKit"]
        )
    ]
)
