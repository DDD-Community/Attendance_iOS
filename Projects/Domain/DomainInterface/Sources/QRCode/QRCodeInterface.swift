//
//  QRCodeInterface.swift
//  DomainInterface
//
//  Created by Wonji Suh  on 7/23/25.
//  Updated for WeaveDI v4.0 - Protocol-based DI Registration
//

import Foundation
import SwiftUI
import Entity
import WeaveDI

/// QRCode 관련 비즈니스 로직을 위한 Interface 프로토콜
public protocol QRCodeInterface: Sendable {
  func createQRCode(userID: Int) async throws -> String
  func generateQRCode(from string: String) async -> Image?
  func qrValidateCheck(from code: String) async throws -> QRValidateEntity
}

/// QRCode Repository의 DependencyKey 구조체
public struct QRCodeRepositoryDependency: DependencyKey {
  public static var liveValue: QRCodeInterface {
    UnifiedDI.resolve(QRCodeInterface.self) ?? DefaultQRCodeRepositoryImpl()
  }

  public static var testValue: QRCodeInterface {
    UnifiedDI.resolve(QRCodeInterface.self) ?? DefaultQRCodeRepositoryImpl()
  }

  public static var previewValue: QRCodeInterface = liveValue
}

/// DependencyValues extension으로 간편한 접근 제공
public extension DependencyValues {
  var qrCodeRepository: QRCodeInterface {
    get { self[QRCodeRepositoryDependency.self] }
    set { self[QRCodeRepositoryDependency.self] = newValue }
  }
}
