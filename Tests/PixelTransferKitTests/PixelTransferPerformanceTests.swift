import CoreVideo
import XCTest
import ImageIO

@testable import PixelTransferKit

final class PixelTransferPerformanceTests: XCTestCase {
  
  let testCount = 1000
  
  func testVImagePerformance() async throws {
    let width = 1920
    let height = 1080
    let sourcePixelBuffer: CVPixelBuffer? = createImage(size: CGSize(width: width, height: height), format: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
    
    measure {
      for _ in 0 ..< testCount {
        _ = try? sourcePixelBuffer?.toBGRA()
      }
    }
  }
  
  func testBlueDressPerformance() async throws  {
    let width = 1920
    let height = 1080
    let sourcePixelBuffer: CVPixelBuffer? = createImage(size: CGSize(width: width, height: height), format: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
    
    let blueDress = BlueDress()
    measure {
      for _ in 0 ..< testCount {
        do {
          let _ = try! blueDress.convert(pixelBuffer: sourcePixelBuffer!)
        }
      }
    }
  }
  
  func testPixelTransferKitPerformance() async throws {
    let width = 1920
    let height = 1080
    let sourcePixelBuffer: CVPixelBuffer? = createImage(size: CGSize(width: width, height: height), format: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
    let destinationPixelFormat: OSType = kCVPixelFormatType_32BGRA
    let pixelTransferKit = try PixelTransferKit()
    
    measure {
      for _ in 0 ..< testCount {
        _ = try! pixelTransferKit.convertPixelBuffer(sourcePixelBuffer!, to: destinationPixelFormat)
      }
    }
  }
}
