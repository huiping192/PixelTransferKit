# PixelTransferKit

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

```
targets: [
    .target(
        name: "YourTarget",
        dependencies: ["PixelTransferKit"]),
]
```

## Usage


```
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

