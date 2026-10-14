// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "WiFiName",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "WiFiName",
            path: "Sources/WiFiName"
        )
    ],
    swiftLanguageVersions: [.v5]
)
