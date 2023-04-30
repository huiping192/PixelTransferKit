import CoreVideo
import XCTest
import ImageIO

@testable import PixelTransferKit

final class PixelTransferKitTests: XCTestCase {
  
  func testVideoToolboxSessionConversion() async throws {
    let width = 1920
    let height = 1080
    let sourcePixelBuffer: CVPixelBuffer? = createImage(size: CGSize(width: width, height: height), format: kCVPixelFormatType_32BGRA)
    
    let destinationPixelFormat: OSType = kCVPixelFormatType_32BGRA
    
    let pixelTransferKit = try PixelTransferKit(pixelTransferMethod: .videoToolboxSession)
    let convertedPixelBuffer = try await pixelTransferKit.convertPixelBuffer(sourcePixelBuffer!, to: destinationPixelFormat)
    
    XCTAssertNotNil(convertedPixelBuffer, "Pixel buffer conversion with VideoToolboxSession failed.")
  }
  
  func testVImageConversion() async throws {
    let sourcePixelBuffer: CVPixelBuffer = loadTestImage()!
    
    let destinationPixelFormat: OSType = kCVPixelFormatType_32BGRA
    
    let pixelTransferKit = try PixelTransferKit(pixelTransferMethod: .vImage)
    let convertedPixelBuffer = try await pixelTransferKit.convertPixelBuffer(sourcePixelBuffer, to: destinationPixelFormat)
    
    XCTAssertNotNil(convertedPixelBuffer, "Pixel buffer conversion with vImage failed.")
  }
  
}
