import Foundation
import VideoToolbox
import CoreVideo

public enum PixelTransferError: Error, CustomStringConvertible {
  
  case sessionCreationFailed(OSStatus)
  case settingPropertiesFailed(OSStatus)
  case sessionNotAvailable
  case destinationPixelBufferCreationFailed(OSStatus)
  case destinationPixelBufferNotAvailable
  case pixelBufferTransferFailed(OSStatus)
  
  
  public var description: String {
    switch self {
    case .sessionCreationFailed(let statusCode):
      return "Error creating VTPixelTransferSession: \(statusCode)"
    case .settingPropertiesFailed(let statusCode):
      return "Error setting VTPixelTransferSession properties: \(statusCode)"
    case .sessionNotAvailable:
      return "VTPixelTransferSession is not available"
    case .destinationPixelBufferCreationFailed(let statusCode):
      return "Error creating destination pixel buffer: \(statusCode)"
    case .destinationPixelBufferNotAvailable:
      return "Destination pixel buffer is not available"
    case .pixelBufferTransferFailed(let statusCode):
      return "Error transferring pixel buffer: \(statusCode)"
    }
  }
}

public class PixelTransferKit {
  private var pixelTransferSession: VTPixelTransferSession?
  
  public init(realTime: Bool = true) throws {
    var session: VTPixelTransferSession?
    let status = VTPixelTransferSessionCreate(allocator: kCFAllocatorDefault, pixelTransferSessionOut: &session)
    if status == noErr, let transferSession = session {
      print("[PixelTransferKit] Successfully created VTPixelTransferSession")
      pixelTransferSession = transferSession
    } else {
      print("[PixelTransferKit] Error creating VTPixelTransferSession: \(status)")
      throw PixelTransferError.sessionCreationFailed(status)
    }
    
    if let pixelTransferSession {
      let properties: NSDictionary = [
        kVTPixelTransferPropertyKey_RealTime: (realTime ? kCFBooleanTrue : kCFBooleanFalse) as Any
      ]
      let setPropertyStatus = VTSessionSetProperties(pixelTransferSession, propertyDictionary: properties)
      if setPropertyStatus == noErr {
        print("[PixelTransferKit] Successfully set VTPixelTransferSession properties")
      } else {
        print("[PixelTransferKit] Error setting VTPixelTransferSession properties: \(setPropertyStatus)")
        throw PixelTransferError.settingPropertiesFailed(setPropertyStatus)
      }
    }
  }
  
  deinit {
    if let session = pixelTransferSession {
      VTPixelTransferSessionInvalidate(session)
    }
  }
  
  public func convertPixelBuffer(_ sourcePixelBuffer: CVPixelBuffer, to destinationPixelFormat: OSType) throws -> CVPixelBuffer {
    guard let session = pixelTransferSession else {
      print("[PixelTransferKit] VTPixelTransferSession is not available")
      throw PixelTransferError.sessionNotAvailable
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
      throw PixelTransferError.destinationPixelBufferCreationFailed(status)
    }
    
    guard let outputPixelBuffer = destinationPixelBuffer else {
      print("[PixelTransferKit] Destination pixel buffer is not available")
      throw PixelTransferError.destinationPixelBufferNotAvailable
    }
    
    let transferStatus = VTPixelTransferSessionTransferImage(session, from: sourcePixelBuffer, to: outputPixelBuffer)
    
    if transferStatus == noErr {
      print("[PixelTransferKit] Successfully transferred pixel buffer")
    } else {
      print("[PixelTransferKit] Error transferring pixel buffer: \(transferStatus)")
      throw PixelTransferError.pixelBufferTransferFailed(transferStatus)
    }
    
    return outputPixelBuffer
  }
}
