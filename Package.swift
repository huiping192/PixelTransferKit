// swift-tools-version: 5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PixelTransferKit",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "PixelTransferKit",
            targets: ["PixelTransferKit"]),
    ],
    dependencies: [
      .package(url: "https://github.com/huiping192/BlueDress", branch: "feature/bundle-crash")
    ],
    targets: [
        .target(
            name: "PixelTransferKit",
            dependencies: []),
        .testTarget(
          name: "PixelTransferKitTests",
          dependencies: [
            "PixelTransferKit",
            .product(name: "BlueDress", package: "BlueDress")
          ],
          resources: [
            .copy("Resources/test.jpeg")
          ]),
    ]
)
