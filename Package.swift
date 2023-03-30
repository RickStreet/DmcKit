// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DmcKit",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "DmcKit",
            targets: ["DmcKit"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        /*.package(
            url: "https://github.com/RickStreet/StringKit.git",
            .branch("master")
        ),*/
        .package(url: "https://github.com/RickStreet/StringKit.git", from: "1.0.40"),
        .package(url: "https://github.com/RickStreet/DoubleKit.git", from: "1.0.6"),
        .package(url: "https://github.com/RickStreet/DialogKit.git", from: "2.0.0")
        // .package(url: "https://github.com/RickStreet/FileKit.git", from: "1.2.6")

        
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "DmcKit",
            dependencies: ["StringKit", "DoubleKit", "DialogKit"]),
        .testTarget(
            name: "DmcKitTests",
            dependencies: ["DmcKit", "StringKit", "DoubleKit", "DialogKit"]),
    ]
)
