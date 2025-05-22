//
//  QRCodeUseCase.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/11/24.
//

import SwiftUI

import Model

import DiContainer
import ComposableArchitecture

public struct QRCodeUseCase: QRCodeUseCaseProtocol {
  private let repository: QRCodeRepositoryProtocol

  public init(
    repository: QRCodeRepositoryProtocol
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

extension DependencyContainer {
  var qrCodeUseCase: QRCodeRepositoryProtocol? {
    resolve(QRCodeRepositoryProtocol.self)
  }
}

extension QRCodeUseCase: DependencyKey {
  public static var liveValue: QRCodeUseCase = {
    let qrCodeRepository = ContainerResgister(\.qrCodeUseCase).wrappedValue
    return QRCodeUseCase(repository: qrCodeRepository)
  }()
}

public extension DependencyValues {
  var qrCodeUseCase: QRCodeUseCase {
    get { self[QRCodeUseCase.self] }
    set { self[QRCodeUseCase.self] = newValue  }
  }
}


public extension RegisterModule {
  var qrCodeUseCaseModule: () -> Module {
    makeUseCaseWithRepository(
      QRCodeUseCaseProtocol.self,
      repositoryProtocol: QRCodeRepositoryProtocol.self,
      repositoryFallback: DefaultQRCodeRepository(),
      factory: { repo in
        QRCodeUseCase(repository: repo)
      }
    )
  }

  var qrCodeRepositoryModule: () -> Module {
    makeDependency(QRCodeRepositoryProtocol.self) {
      QRCodeRepository()
    }
  }
}
