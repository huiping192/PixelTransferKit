import CoreVideo
import XCTest
import ImageIO

@testable import PixelTransferKit

final class VTPixelTransferKitTests: XCTestCase {
  func testPixelBufferConversion32BGRATo420YpCbCr8BiPlanarFullRange() async throws {
    let width = 1920
    let height = 1080
    let sourcePixelBuffer: CVPixelBuffer? = createImage(size: CGSize(width: width, height: height), format: kCVPixelFormatType_32BGRA)
    
    let pixelTransferKit = try PixelTransferKit()
    
    let destinationPixelFormat = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
    let convertedPixelBuffer = try pixelTransferKit.convertPixelBuffer(sourcePixelBuffer!, to: destinationPixelFormat)
    
    XCTAssertNotNil(convertedPixelBuffer)
    XCTAssertEqual(CVPixelBufferGetPixelFormatType(convertedPixelBuffer), destinationPixelFormat)
    XCTAssertEqual(CVPixelBufferGetWidth(convertedPixelBuffer), width)
    XCTAssertEqual(CVPixelBufferGetHeight(convertedPixelBuffer), height)
  }
  
  func testPixelBufferConversionFromImage() async throws {
    let sourcePixelBuffer: CVPixelBuffer = loadTestImage(format: kCVPixelFormatType_420YpCbCr8Planar)!
    let width = CVPixelBufferGetWidth(sourcePixelBuffer)
    let height = CVPixelBufferGetHeight(sourcePixelBuffer)
    
    // Create a PixelTransferKit instance
    let pixelTransferKit = try PixelTransferKit()
    
    // Convert the source pixel buffer to kCVPixelFormatType_420YpCbCr8BiPlanarFullRange format
    let destinationPixelFormat = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
    let convertedPixelBuffer = try pixelTransferKit.convertPixelBuffer(sourcePixelBuffer, to: destinationPixelFormat)
    
    // Check if the conversion was successful
    XCTAssertNotNil(convertedPixelBuffer)
    XCTAssertEqual(CVPixelBufferGetPixelFormatType(convertedPixelBuffer), destinationPixelFormat)
    XCTAssertEqual(CVPixelBufferGetWidth(convertedPixelBuffer), width)
    XCTAssertEqual(CVPixelBufferGetHeight(convertedPixelBuffer), height)
  }
  
}
