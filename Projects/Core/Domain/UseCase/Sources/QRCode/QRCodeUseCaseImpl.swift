//
//  QRCodeUseCaseImpl.swift
//  UseCase
//
//  Created by Wonji Suh  on 7/23/25.
//

import SwiftUI

import DomainInterface
import Model
import Repository

import ComposableArchitecture
import WeaveDI

public struct QRCodeUseCaseImpl: QRCodeInterface {
  private let repository: QRCodeInterface

  public init(
    repository: QRCodeInterface
  ) {
    self.repository = repository
  }

  public func createQRCode() async throws -> String {
    return try await repository.createQRCode()
  }

  public func generateQRCode(from string: String) async -> Image? {
    await repository.generateQRCode(from: string)
  }

  // MARK: - qrcode 출석체크
  public func qrAttendanceCheck(
    from code: String
  ) async throws -> QRValidateModel? {
    return try await repository.qrAttendanceCheck(from: code)
  }
}

extension QRCodeUseCaseImpl: DependencyKey {
  public static var liveValue: QRCodeInterface = {
    let repository = UnifiedDI.register(QRCodeInterface.self) {
      QRCodeRepositoryImpl()
    }
    return QRCodeUseCaseImpl(repository: repository)
  }()
}

public extension DependencyValues {
  var qrCodeUseCase: QRCodeInterface {
    get { self[QRCodeUseCaseImpl.self] }
    set { self[QRCodeUseCaseImpl.self] = newValue  }
  }
}

