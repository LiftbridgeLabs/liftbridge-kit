// swift-tools-version: 6.0
import PackageDescription

// Shared code for Liftbridge Labs apps. Each library is its own product, so an
// app pulls in only what it uses. macOS is listed only so `swift test` runs on
// the Mac (and in CI) without a simulator.
let package = Package(
    name: "LiftbridgeKit",
    platforms: [.iOS(.v18), .tvOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "LiftbridgeThemes", targets: ["LiftbridgeThemes"]),
    ],
    targets: [
        .target(name: "LiftbridgeThemes"),
        .testTarget(name: "LiftbridgeThemesTests", dependencies: ["LiftbridgeThemes"]),
        // `swift run Gallery`: a page showing every theme's colors (not shipped to apps).
        .executableTarget(name: "Gallery", dependencies: ["LiftbridgeThemes"]),
    ]
)
