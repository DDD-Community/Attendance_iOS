//
//  QRCodeRepositoryImpl.swift
//  Repository
//
//  Created by Wonji Suh  on 7/23/25.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

import DomainInterface
import Model
import Service

import AsyncMoya

@Observable
public class QRCodeRepository: QRCodeInterface {

  public init() {}

  private let provider = MoyaProvider<QRService>(session: Session(interceptor: AuthInterceptor.shared), plugins: [MoyaLoggingPlugin()])

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
    let qrModel = try await provider.requestAsyncAwait(
      .qrAttendanceCheck(
        code: code
      ), decodeTo: QRValidateDTOModel.self)

    return qrModel.toDomain()
  }
}

