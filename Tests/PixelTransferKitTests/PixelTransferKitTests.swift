import CoreVideo
import XCTest
import ImageIO

@testable import PixelTransferKit

final class PixelTransferKitTests: XCTestCase {
  
  func testVideoToolboxSessionConversion() async throws {
    let width = 1920
    let height = 1080
    
    var sourcePixelBuffer: CVPixelBuffer?
    let sourceStatus = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, nil, &sourcePixelBuffer)
    XCTAssertEqual(sourceStatus, kCVReturnSuccess)
    XCTAssertNotNil(sourcePixelBuffer)
    
    let destinationPixelFormat: OSType = kCVPixelFormatType_32BGRA
    
    let pixelTransferKit = try PixelTransferKit(pixelTransferMethod: .videoToolboxSession)
    let convertedPixelBuffer = try await pixelTransferKit.convertPixelBuffer(sourcePixelBuffer!, to: destinationPixelFormat)
    
    XCTAssertNotNil(convertedPixelBuffer, "Pixel buffer conversion with VideoToolboxSession failed.")
  }
  
  func testVImageConversion() async throws {
    // Load an image from the bundle
    let bundle = Bundle.module
    guard let imageURL = bundle.url(forResource: "test", withExtension: "jpeg") else {
      XCTFail("Test image not found in the bundle.")
      return
    }
    
    guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, nil),
          let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
      XCTFail("Failed to load test image.")
      return
    }
    
    // Convert the image to a CVPixelBuffer
    let width = cgImage.width
    let height = cgImage.height
    var sourcePixelBuffer: CVPixelBuffer?
    let sourceStatus = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, nil, &sourcePixelBuffer)
    XCTAssertEqual(sourceStatus, kCVReturnSuccess)
    XCTAssertNotNil(sourcePixelBuffer)
    
    let destinationPixelFormat: OSType = kCVPixelFormatType_32BGRA
    
    let pixelTransferKit = try PixelTransferKit(pixelTransferMethod: .vImage)
    let convertedPixelBuffer = try await pixelTransferKit.convertPixelBuffer(sourcePixelBuffer!, to: destinationPixelFormat)
    
    XCTAssertNotNil(convertedPixelBuffer, "Pixel buffer conversion with vImage failed.")
  }
  
}
