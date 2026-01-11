//
//  QRCodeUseCaseImpl.swift
//  UseCase
//
//  Created by Wonji Suh  on 7/23/25.
//

import SwiftUI

import DomainInterface
import Entity

import WeaveDI

public struct QRCodeUseCaseImpl: QRCodeInterface {
  @Dependency(\.qrCodeRepository) var repository

  public init() { }

  public func createQRCode() async throws -> String {
    return try await repository.createQRCode()
  }

  public func generateQRCode(from string: String) async -> Image? {
    await repository.generateQRCode(from: string)
  }

  // MARK: - qrcode 출석체크
  public func qrValidateCheck(
    from code: String
  ) async throws -> QRValidateEntity {
    return try await repository.qrValidateCheck(from: code)
  }
}

extension QRCodeUseCaseImpl: DependencyKey {
  public static var liveValue: QRCodeInterface = QRCodeUseCaseImpl()
  public static var testValue: QRCodeInterface = QRCodeUseCaseImpl()
  public static var previewValue: QRCodeInterface = liveValue
}

public extension DependencyValues {
  var qrCodeUseCase: QRCodeInterface {
    get { self[QRCodeUseCaseImpl.self] }
    set { self[QRCodeUseCaseImpl.self] = newValue  }
  }
}

