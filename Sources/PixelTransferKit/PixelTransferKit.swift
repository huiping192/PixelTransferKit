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

protocol PixelTransfable {
  func convertPixelBuffer(_ sourcePixelBuffer: CVPixelBuffer, to destinationPixelFormat: OSType) throws -> CVPixelBuffer
}

public enum PixelTransferMethod {
    case videoToolboxSession
    case vImage
}

public actor PixelTransferKit {
  
  private let pixelTransfable: PixelTransfable
    
  init(pixelTransferMethod: PixelTransferMethod = .videoToolboxSession) throws {
    switch pixelTransferMethod {
    case .videoToolboxSession:
      self.pixelTransfable = try PixelTransferKitVideoToolBox()
    case .vImage:
      self.pixelTransfable = PixelTransferKitVImage()
    }
  }
  
  func convertPixelBuffer(_ sourcePixelBuffer: CVPixelBuffer, to destinationPixelFormat: OSType) throws -> CVPixelBuffer {
    return try pixelTransfable.convertPixelBuffer(sourcePixelBuffer, to: destinationPixelFormat)
  }
}
