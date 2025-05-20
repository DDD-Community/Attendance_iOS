//
//  QrCodeUseCase.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/11/24.
//

import SwiftUI

import Model

import DiContainer
import ComposableArchitecture


public struct QrCodeUseCase: QrCodeUseCaseProtocol {
  private let repository: QrCodeRepositoryProtcol
  
  public init(
    repository: QrCodeRepositoryProtcol
  ) {
    self.repository = repository
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
  var qrCodeUseCase: QrCodeRepositoryProtcol? {
    resolve(QrCodeRepositoryProtcol.self)
  }
}

extension QrCodeUseCase: DependencyKey {
  public static var liveValue: QrCodeUseCase = {
    let qrCodeRepository = ContainerResgister(\.qrCodeUseCase).wrappedValue
    return QrCodeUseCase(repository: qrCodeRepository)
  }()
}

public extension DependencyValues {
  var qrCodeUseCase: QrCodeUseCase {
    get { self[QrCodeUseCase.self] }
    set { self[QrCodeUseCase.self] = newValue  }
  }
}


public extension RegisterModule {
  var qrCodeUseCaseModule: () -> Module {
    makeUseCaseWithRepository(
      QrCodeUseCaseProtocol.self,
      repositoryProtocol: QrCodeRepositoryProtcol.self,
      repositoryFallback: DefaultQrCodeRepository(),
      factory: { repo in
        QrCodeUseCase(repository: repo)
      }
    )
  }
  
  var qrCodeRepositoryModule: () -> Module {
    makeDependency(QrCodeRepositoryProtcol.self) {
      QrCodeRepository()
    }
  }
}
