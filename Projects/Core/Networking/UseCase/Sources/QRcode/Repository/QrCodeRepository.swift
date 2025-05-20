//
//  QrCodeRepository.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/11/24.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

import Service
import Model

import AsyncMoya

@Observable
public class QrCodeRepository: QrCodeRepositoryProtcol {
  
  private let provider = MoyaProvider<QRService>(plugins: [MoyaLoggingPlugin()])
  public init() {}
  
  // MARK: - QRCode 생성
  
  public func generateQRCode(from string: String) async -> SwiftUI.Image? {
    await withCheckedContinuation { continuation in
      let context = CIContext()
      let filter = CIFilter.qrCodeGenerator()
      let data = Data(string.utf8)
      
      filter.setValue(data, forKey: "inputMessage")
      
      if let outputImage = filter.outputImage {
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
          let swiftUIImage = SwiftUI.Image(decorative: cgimg, scale: 1.0)
          continuation.resume(returning: swiftUIImage)
          return
        }
      }
      
      continuation.resume(returning: nil)
    }
  }
  
  public func qrAttendanceCheck(
    from code: String
  ) async throws -> QRValidateModel? {
    let qrModel = try await provider.requestAsync(
      .qrAttendanceCheck(
        code: code
      ), decodeTo: QRValidateDTOModel.self)
    
    return qrModel.toDomain()
  }
}
