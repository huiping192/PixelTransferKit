import Foundation
import CoreVideo
import CoreImage

func createImage(size: CGSize, format: OSType) -> CVPixelBuffer? {
  let width = 1920
  let height = 1080
  
  var sourcePixelBuffer: CVPixelBuffer?
  let attributes: [CFString: Any] = [
          kCVPixelBufferWidthKey: width,
          kCVPixelBufferHeightKey: height,
          kCVPixelBufferPixelFormatTypeKey: format,
          kCVPixelBufferMetalCompatibilityKey: kCFBooleanTrue
      ]
  CVPixelBufferCreate(kCFAllocatorDefault, width, height, format, attributes as CFDictionary, &sourcePixelBuffer)
  return sourcePixelBuffer
}

func loadTestImage(format: OSType) -> CVPixelBuffer?  {
  let bundle = Bundle.module
  guard let imageURL = bundle.url(forResource: "test", withExtension: "jpeg") else {
    return nil
  }
  
  guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, nil),
        let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
    return nil
  }
  
  // Convert the image to a CVPixelBuffer
  let width = cgImage.width
  let height = cgImage.height
  var sourcePixelBuffer: CVPixelBuffer?
  let attributes: [CFString: Any] = [
          kCVPixelBufferWidthKey: width,
          kCVPixelBufferHeightKey: height,
          kCVPixelBufferPixelFormatTypeKey: format,
          kCVPixelBufferMetalCompatibilityKey: kCFBooleanTrue
      ]
  let sourceStatus = CVPixelBufferCreate(kCFAllocatorDefault, width, height, format, attributes as CFDictionary, &sourcePixelBuffer)
  if sourceStatus != noErr || sourcePixelBuffer == nil {
    return nil
  }
  
  CVPixelBufferLockBaseAddress(sourcePixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
  let baseAddress = CVPixelBufferGetBaseAddress(sourcePixelBuffer!)
  
  let colorSpace = CGColorSpaceCreateDeviceRGB()
  let bitmapInfo: CGBitmapInfo = [.byteOrder32Little, CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)]
  let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(sourcePixelBuffer!), space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
  context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
  
  CVPixelBufferUnlockBaseAddress(sourcePixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
  
  return sourcePixelBuffer
}
