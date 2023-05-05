//
//  File.swift
//  
//
//  Created by 郭 輝平 on 2023/05/05.
//

import Foundation
import BlueDress
import CoreVideo

class BlueDress {
  let converter = try? YCbCrImageBufferConverter()
  
  func convert(pixelBuffer: CVPixelBuffer) throws -> CVPixelBuffer?  {
    return try converter?.convertToBGRA(imageBuffer: pixelBuffer)
  }
}
