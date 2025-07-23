//
//  QRCodeUseCaseImpl.swift
//  UseCase
//
//  Created by Wonji Suh  on 7/23/25.
//

import SwiftUI


import DiContainer
import DomainInterface
import Model
import Repository

import ComposableArchitecture

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

extension DependencyContainer {
  var qrCodeUseCase: QRCodeInterface? {
    resolve(QRCodeInterface.self)
  }
}

extension QRCodeUseCaseImpl: DependencyKey {
  public static var liveValue: QRCodeInterface = {
    let repository = ContainerResgister(\.qrCodeUseCase).wrappedValue
    return QRCodeUseCaseImpl(repository: repository)
  }()
}

public extension DependencyValues {
  var qrCodeUseCase: QRCodeInterface {
    get { self[QRCodeUseCaseImpl.self] }
    set { self[QRCodeUseCaseImpl.self] = newValue  }
  }
}


public extension RegisterModule {
  var qrCodeUseCaseImplModule: () -> Module {
    makeUseCaseWithRepository(
      QRCodeInterface.self,
      repositoryProtocol: QRCodeInterface.self,
      repositoryFallback: DefaultQRCodeRepositoryImpl(),
      factory: { repo in
        QRCodeUseCaseImpl(repository: repo)
      }
    )
  }

  var qrCodeRepositoryImplModule: () -> Module {
    makeDependency(QRCodeInterface.self) {
      QRCodeRepositoryImpl()
    }
  }
}

