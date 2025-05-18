//
//  QRCodeRepository.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/11/24.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

import Model
import Service

import AsyncMoya

@Observable
public class QRCodeRepository: QRCodeRepositoryProtocol {

  public init() {}

  private let provider = MoyaProvider<QRCodeService>(plugins: [MoyaLoggingPlugin()])

  // MARK: - QRCode String 생성

  public func createQRCode() async throws -> String {
    let response = try await provider.requestAsync(.createQRCode, decodeTo: BaseResponseDTO<CreateQRCodeResponseDTO>.self)
    return response.data.qrString
  }

  // MARK: - QRCode Image 생성

  public func generateQRCode(from string: String) async -> SwiftUI.Image? {
    await withCheckedContinuation { continuation in
      let filter = CIFilter.qrCodeGenerator()
      let data = Data(string.utf8)

      filter.setValue(data, forKey: "inputMessage")

      if let outputImage = filter.outputImage {
        if let cgimg = CIContext().createCGImage(outputImage, from: outputImage.extent) {
          let swiftUIImage = Image(decorative: cgimg, scale: 1.0)
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
