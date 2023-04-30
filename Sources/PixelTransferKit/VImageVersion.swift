import Foundation
import Accelerate.vImage
import CoreVideo

public actor PixelTransferKitVImage {
  
  public init() {
  }
  
  private var converter: vImageConverter?
  
  func createConverter(cvImageFormat: vImageCVImageFormat) -> vImageConverter? {
    var cgImageFormat = vImage_CGImageFormat(
      bitsPerComponent: 8,
      bitsPerPixel: 32,
      colorSpace: nil,
      bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue),
      version: 0,
      decode: nil,
      renderingIntent: .defaultIntent)
    
    var error = kvImageNoError
    vImageCVImageFormat_SetColorSpace(cvImageFormat, CGColorSpaceCreateDeviceRGB())
    
    vImageCVImageFormat_SetChromaSiting(cvImageFormat, kCVImageBufferChromaLocation_Center)
    
    guard let unmanagedConverter = vImageConverter_CreateForCVToCGImageFormat(
      cvImageFormat,
      &cgImageFormat,
      nil,
      vImage_Flags(kvImagePrintDiagnosticsToConsole),
      &error),
          error == kvImageNoError else {
      print("vImageConverter_CreateForCVToCGImageFormat error:", error)
      return nil
    }
    
    return unmanagedConverter.takeRetainedValue()
  }
  
  func convertPixelBuffer(_ pixelBuffer: CVPixelBuffer, toPixelFormatType: OSType) -> CVPixelBuffer? {
    // Get the source buffer's attributes
    let width = CVPixelBufferGetWidth(pixelBuffer)
    let height = CVPixelBufferGetHeight(pixelBuffer)
    
    // Create a destination pixel buffer with the desired pixel format
    var outputPixelBuffer: CVPixelBuffer?
    let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, toPixelFormatType, nil, &outputPixelBuffer)
    guard status == kCVReturnSuccess, let outputPixelBuffer = outputPixelBuffer else { return nil }
    
    // Create vImage buffers from source and destination pixel buffers
    var sourceBuffer = getImageBuffer(from: pixelBuffer)
    var destinationBuffer = getImageBuffer(from: outputPixelBuffer)
    
    if converter == nil {
      let cvImageFormat = vImageCVImageFormat_CreateWithCVPixelBuffer(pixelBuffer).takeRetainedValue()
      self.converter = createConverter(cvImageFormat: cvImageFormat)
    }
    
    // Perform the pixel format conversion
    let error = vImageConvert_AnyToAny(converter!, &sourceBuffer!, &destinationBuffer!, nil, vImage_Flags(kvImageNoFlags))
    guard error == kvImageNoError else { return nil }
    
    return outputPixelBuffer
  }
  
  func getImageBuffer(from pixelBuffer: CVPixelBuffer) -> vImage_Buffer? {
    var buffer = vImage_Buffer()
    let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.first.rawValue)
    let pixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer)
    var cgFormat = vImage_CGImageFormat(bitsPerComponent: 8,
                                        bitsPerPixel: 32,
                                        colorSpace: nil,
                                        bitmapInfo: bitmapInfo,
                                        version: 0,
                                        decode: nil,
                                        renderingIntent: .defaultIntent)
    let cvFormat = vImageCVImageFormat_Create(pixelFormat,
                                              kvImage_ARGBToYpCbCrMatrix_ITU_R_709_2,
                                              kCVImageBufferChromaLocation_TopLeft,
                                              CGColorSpaceCreateDeviceRGB(), 0).takeRetainedValue()
    
    var error: vImage_Error
    error = vImageBuffer_InitWithCVPixelBuffer(&buffer,
                                               &cgFormat,
                                               pixelBuffer,
                                               cvFormat,
                                               nil,
                                               vImage_Flags(0))
    guard error == kvImageNoError else { return nil }
    
    return buffer
  }
  
}
