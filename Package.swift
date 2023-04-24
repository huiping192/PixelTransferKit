// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PixelTransferKit",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PixelTransferKit",
            targets: ["PixelTransferKit"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PixelTransferKit"),
        .testTarget(
            name: "PixelTransferKitTests",
            dependencies: ["PixelTransferKit"]),
    ]
)
