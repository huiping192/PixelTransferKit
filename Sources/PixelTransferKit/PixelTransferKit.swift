import Foundation
import VideoToolbox
import CoreVideo

public actor PixelTransferKit {
  private var pixelTransferSession: VTPixelTransferSession?
  
  public init(realTime: Bool = true) {
    var session: VTPixelTransferSession?
    let status = VTPixelTransferSessionCreate(allocator: kCFAllocatorDefault, pixelTransferSessionOut: &session)
    if status == noErr, let transferSession = session {
      pixelTransferSession = transferSession
    } else {
      print("[PixelTransferKit] Error creating VTPixelTransferSession: \(status)")
    }
    
    if let pixelTransferSession {
      let properties: NSDictionary = [
        kVTPixelTransferPropertyKey_RealTime: (realTime ? kCFBooleanTrue : kCFBooleanFalse) as Any
      ]
      let setPropertyStatus = VTSessionSetProperties(pixelTransferSession, propertyDictionary: properties)
      if setPropertyStatus != noErr {
        print("[PixelTransferKit] Error setting VTPixelTransferSession properties: \(setPropertyStatus)")
      }
    }
  }
  
  deinit {
    if let session = pixelTransferSession {
      VTPixelTransferSessionInvalidate(session)
    }
  }
  
  public func convertPixelBuffer(_ sourcePixelBuffer: CVPixelBuffer, to destinationPixelFormat: OSType) -> CVPixelBuffer? {
    guard let session = pixelTransferSession else {
      print("[PixelTransferKit] VTPixelTransferSession is not available")
      return nil
    }
    
    let pixelBufferAttributes: [CFString: Any] = [
      kCVPixelBufferPixelFormatTypeKey: destinationPixelFormat,
      kCVPixelBufferWidthKey: CVPixelBufferGetWidth(sourcePixelBuffer),
      kCVPixelBufferHeightKey: CVPixelBufferGetHeight(sourcePixelBuffer),
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
      print("[PixelTransferKit] Error creating destination pixel buffer: \(status)")
      return nil
    }
    
    guard let outputPixelBuffer = destinationPixelBuffer else {
      print("[PixelTransferKit] Destination pixel buffer is not available")
      return nil
    }
    
    let transferStatus = VTPixelTransferSessionTransferImage(session, from: sourcePixelBuffer, to: outputPixelBuffer)
    
    if transferStatus != noErr {
      print("[PixelTransferKit] Error transferring pixel buffer: \(transferStatus)")
      return nil
    }
    
    return outputPixelBuffer
  }
}
