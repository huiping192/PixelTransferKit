import CoreVideo
import XCTest
import ImageIO

@testable import PixelTransferKit

final class PixelTransferKitTests: XCTestCase {
  func testPixelBufferConversion32BGRATo420YpCbCr8BiPlanarFullRange() async throws {
    let width = 1920
    let height = 1080
    
    var sourcePixelBuffer: CVPixelBuffer?
    let sourceStatus = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, nil, &sourcePixelBuffer)
    XCTAssertEqual(sourceStatus, kCVReturnSuccess)
    XCTAssertNotNil(sourcePixelBuffer)
    
    let pixelTransferKit = try PixelTransferKit()
    
    let destinationPixelFormat = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
    let convertedPixelBuffer = try await pixelTransferKit.convertPixelBuffer(sourcePixelBuffer!, to: destinationPixelFormat)
    
    XCTAssertNotNil(convertedPixelBuffer)
    XCTAssertEqual(CVPixelBufferGetPixelFormatType(convertedPixelBuffer!), destinationPixelFormat)
    XCTAssertEqual(CVPixelBufferGetWidth(convertedPixelBuffer!), width)
    XCTAssertEqual(CVPixelBufferGetHeight(convertedPixelBuffer!), height)
  }
  
  
  
  func testPixelBufferConversionFromImage() async throws {
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
    
    CVPixelBufferLockBaseAddress(sourcePixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
    let baseAddress = CVPixelBufferGetBaseAddress(sourcePixelBuffer!)
    
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo: CGBitmapInfo = [.byteOrder32Little, CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)]
    let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(sourcePixelBuffer!), space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
    context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
    
    CVPixelBufferUnlockBaseAddress(sourcePixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
    
    // Create a PixelTransferKit instance
    let pixelTransferKit = try PixelTransferKit()
    
    // Convert the source pixel buffer to kCVPixelFormatType_420YpCbCr8BiPlanarFullRange format
    let destinationPixelFormat = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
    let convertedPixelBuffer = try await pixelTransferKit.convertPixelBuffer(sourcePixelBuffer!, to: destinationPixelFormat)
    
    // Check if the conversion was successful
    XCTAssertNotNil(convertedPixelBuffer)
    XCTAssertEqual(CVPixelBufferGetPixelFormatType(convertedPixelBuffer!), destinationPixelFormat)
    XCTAssertEqual(CVPixelBufferGetWidth(convertedPixelBuffer!), width)
    XCTAssertEqual(CVPixelBufferGetHeight(convertedPixelBuffer!), height)
  }
  
}
