import Foundation
import Accelerate.vImage
import CoreVideo


public class PixelTransferKitVImage: PixelTransfable {
  public init() {
  }
  
  private var converter: vImageConverter?
  
  func createConverter(cvImageFormat: vImageCVImageFormat) throws -> vImageConverter {
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
      &error) else {
      throw PixelTransferError.sessionCreationFailed(OSStatus(error))
    }
    
    return unmanagedConverter.takeRetainedValue()
  }
  
  public func convertPixelBuffer(_ sourcePixelBuffer: CVPixelBuffer, to destinationPixelFormat: OSType) throws -> CVPixelBuffer {
    // Get the source buffer's attributes
    let width = CVPixelBufferGetWidth(sourcePixelBuffer)
    let height = CVPixelBufferGetHeight(sourcePixelBuffer)
    
    // Create a destination pixel buffer with the desired pixel format
    var outputPixelBuffer: CVPixelBuffer?
    let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, destinationPixelFormat, nil, &outputPixelBuffer)
    guard status == kCVReturnSuccess, let outputPixelBuffer = outputPixelBuffer else {
      throw PixelTransferError.destinationPixelBufferCreationFailed(status)
    }
    
    // Create vImage buffers from source and destination pixel buffers
    var sourceBuffer = try getImageBuffer(from: sourcePixelBuffer)
    var destinationBuffer = try getImageBuffer(from: outputPixelBuffer)
    
    if converter == nil {
      let cvImageFormat = vImageCVImageFormat_CreateWithCVPixelBuffer(sourcePixelBuffer).takeRetainedValue()
      converter = try createConverter(cvImageFormat: cvImageFormat)
    }
    
    // Perform the pixel format conversion
    let error = vImageConvert_AnyToAny(converter!, &sourceBuffer, &destinationBuffer, nil, vImage_Flags(kvImageNoFlags))
    guard error == kvImageNoError else {
      throw PixelTransferError.pixelBufferTransferFailed(OSStatus(error))
    }
    
    return outputPixelBuffer
  }
  
  func getImageBuffer(from pixelBuffer: CVPixelBuffer) throws -> vImage_Buffer {
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
    guard error == kvImageNoError else {
      throw PixelTransferError.destinationPixelBufferCreationFailed(OSStatus(error))
    }
    
    return buffer
  }
}

