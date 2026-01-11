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
import Entity

@preconcurrency import AsyncMoya

@Observable
final public class QRCodeRepositoryImpl: QRCodeInterface {

  private let provider: MoyaProvider<QRService>

  public init(
    provider: MoyaProvider<QRService> = MoyaProvider<QRService>.authorized
  ) {
    self.provider = provider
  }



  // MARK: - QRCode String 생성

  public func createQRCode() async throws -> String {
    let response : BaseResponseDTO<CreateQRCodeResponseDTO> = try await provider.request(.createQRCode)
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

  public func qrValidateCheck(from code: String) async throws -> Entity.QRValidateEntity {
    let response = try await provider.requestResponse(.qrAttendanceCheck(qrCode: code))
    let decoder = JSONDecoder()

    if (200...299).contains(response.statusCode) {
      if response.data.isEmpty {
        return QRValidateEntity(isSuccess: true)
      }
      if let successDTO = try? decoder.decode(QRValidateDTO.self, from: response.data) {
        return successDTO.toDomain(isSuccess: true)
      }
      return QRValidateEntity(isSuccess: true)
    }
    if let errorDTO = try? decoder.decode(QRValidateDTO.self, from: response.data) {
      return errorDTO.toDomain(isSuccess: false)
    }
    return QRValidateEntity(
      isSuccess: false,
      message: String(data: response.data, encoding: .utf8)
    )
  }
}
