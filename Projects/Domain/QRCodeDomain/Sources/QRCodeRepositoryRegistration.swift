//
//  QRCodeRepositoryRegistration.swift
//  QRCodeDomain
//
//  Created by DDD on 9/4/26.
//

import Dependencies
import QRCodeDomainInterface

public extension DependencyValues {
  mutating func registerQRCodeRepository() {
    qrCodeRepository = resolve { QRCodeRepositoryImpl() }
  }

  private func resolve<Value>(_ makeValue: () -> Value) -> Value {
    withDependencies { $0 = self } operation: { makeValue() }
  }
}
