# PixelTransferKit

[![CI](https://github.com/huiping192/PixelTransferKit/actions/workflows/swift.yml/badge.svg?branch=main)](https://github.com/huiping192/PixelTransferKit/actions/workflows/swift.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)]([https://opensource.org/licenses/MIT](https://github.com/huiping192/LICENSE))
[![Twitter](https://img.shields.io/twitter/follow/huiping192?style=social)](https://twitter.com/huiping192)

PixelTransferKit is a Swift library that provides an easy-to-use interface for converting pixel formats using `VTPixelTransferSession`. The library supports both macOS and iOS platforms.

## Features

- Simple API for converting pixel formats of `CVPixelBuffer`
- Asynchronous and thread-safe operation using Swift's concurrency model
- Customizable properties for the `VTPixelTransferSession`

## Requirements

- Swift 5.5 or later
- macOS 10.15 or later
- iOS 13 or later

## Installation

### Swift Package Manager

Add the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/huiping192/PixelTransferKit.git", .upToNextMajor(from: "0.0.1"))
]
```

Then, add PixelTransferKit to your target dependencies:

```swift
targets: [
    .target(
        name: "YourTarget",
        dependencies: ["PixelTransferKit"]),
]
```

## Usage


```swift
import PixelTransferKit

// Initialize the PixelTransferKit object
let pixelTransferKit = try PixelTransferKit(realTime: true)

// Convert a CVPixelBuffer to another pixel format
let sourcePixelBuffer: CVPixelBuffer = ...
let destinationPixelFormat: OSType = kCVPixelFormatType_32BGRA
let convertedPixelBuffer = try pixelTransferKit.convertPixelBuffer(sourcePixelBuffer, to: destinationPixelFormat)

// Use the converted pixel buffer
...
```

## Contributing

Contributions are welcome! Please submit a pull request or create an issue if you have any improvements, suggestions, or bug reports.

## License

PixelTransferKit is released under the MIT License. See LICENSE for more information.

