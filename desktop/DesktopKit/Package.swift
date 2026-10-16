// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "DesktopKit",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "DesktopKit", targets: ["DesktopKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-perception", from: "2.0.12"),
    ],
    targets: [
        .target(name: "DesktopKit", dependencies: [.product(name: "Perception", package: "swift-perception")], resources: [.copy("Resources/Wallpapers"), .copy("Resources/ColorThemes"), .copy("Resources/Fonts"), .copy("Resources/Icons"), .copy("Resources/Store")]),
        .testTarget(name: "DesktopKitTests", dependencies: ["DesktopKit"], exclude: ["Fixtures"]),
    ]
)
