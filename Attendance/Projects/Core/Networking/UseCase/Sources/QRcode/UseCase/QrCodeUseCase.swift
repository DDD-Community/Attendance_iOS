//
//  QrCodeUseCase.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/11/24.
//

import SwiftUI

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
}

extension QrCodeUseCase: DependencyKey {
  public static var liveValue: QrCodeUseCase = {
    let qrCodeRepository = DependencyContainer.live.resolve(QrCodeRepositoryProtcol.self) ?? DefaultQrCodeRepository()
    return QrCodeUseCase(repository: qrCodeRepository)
  }()
}

public extension DependencyValues {
  var qrCodeUseCase: QrCodeUseCaseProtocol {
    get { self[QrCodeUseCase.self] }
    set { self[QrCodeUseCase.self] = newValue as! QrCodeUseCase}
  }
}
