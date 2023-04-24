import Foundation
import CoreVideo
import CoreMedia

struct ExampleUsage {
  func run() {
    // Create a dummy pixel buffer for demonstration purposes
    var pixelBuffer: CVPixelBuffer?
    let result = CVPixelBufferCreate(kCFAllocatorDefault, 1920, 1080, kCVPixelFormatType_32BGRA, [:] as CFDictionary, &pixelBuffer)
    
    if result != kCVReturnSuccess {
      print("Error creating pixel buffer: \(result)")
      return
    }
    
    guard let inputPixelBuffer = pixelBuffer else {
      print("Input pixel buffer is not available")
      return
    }
    
    // Instantiate the PixelTransferKit class
    let pixelTransferKit = PixelTransferKit()
    
    // Convert the pixel buffer to a new pixel format
    let destinationPixelFormat = kCVPixelFormatType_32ARGB
    if let outputPixelBuffer = pixelTransferKit.convertPixelBuffer(inputPixelBuffer, to: destinationPixelFormat) {
      print("Successfully converted pixel buffer to format: \(destinationPixelFormat)")
    } else {
      print("Failed to convert pixel buffer")
    }
  }
}
