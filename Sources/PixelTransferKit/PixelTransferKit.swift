import Foundation
import VideoToolbox
import CoreVideo

public class PixelTransferKit {
  private var pixelTransferSession: VTPixelTransferSession?
  
  public init() {
    var session: VTPixelTransferSession?
    let status = VTPixelTransferSessionCreate(allocator: kCFAllocatorDefault, pixelTransferSessionOut: &session)
    if status == noErr, let transferSession = session {
      pixelTransferSession = transferSession
    } else {
      print("Error creating VTPixelTransferSession: \(status)")
    }
  }
  
  deinit {
    if let session = pixelTransferSession {
      VTPixelTransferSessionInvalidate(session)
    }
  }
  
  public func convertPixelBuffer(
    _ sourcePixelBuffer: CVPixelBuffer,
    to destinationPixelFormat: OSType,
    options: NSDictionary? = nil
  ) -> CVPixelBuffer? {
    guard let session = pixelTransferSession else {
      print("VTPixelTransferSession is not available")
      return nil
    }
    
    let pixelBufferAttributes: [CFString: Any] = [
      kCVPixelBufferPixelFormatTypeKey: destinationPixelFormat,
      kCVPixelBufferWidthKey: CVPixelBufferGetWidth(sourcePixelBuffer),
      kCVPixelBufferHeightKey: CVPixelBufferGetHeight(sourcePixelBuffer),
      kCVPixelBufferIOSurfacePropertiesKey: [:] as CFDictionary
    ]
    
    var destinationPixelBuffer: CVPixelBuffer?
    let status = CVPixelBufferCreate(
      kCFAllocatorDefault,
      CVPixelBufferGetWidth(sourcePixelBuffer),
      CVPixelBufferGetHeight(sourcePixelBuffer),
      destinationPixelFormat,
      pixelBufferAttributes as CFDictionary,
      &destinationPixelBuffer
    )
    
    if status != kCVReturnSuccess {
      print("Error creating destination pixel buffer: \(status)")
      return nil
    }
    
    guard let outputPixelBuffer = destinationPixelBuffer else {
      print("Destination pixel buffer is not available")
      return nil
    }
    
    let transferStatus = VTPixelTransferSessionTransferImage(session, from: sourcePixelBuffer, to: outputPixelBuffer)
    
    if transferStatus != noErr {
      print("Error transferring pixel buffer: \(transferStatus)")
      return nil
    }
    
    return outputPixelBuffer
  }
}
