//
//  DefaultQRCodeRepositoryImpl.swift
//  Repository
//
//  Created by DDD on 7/23/25.
//

import SwiftUI

import Model
import Entity

final public class DefaultQRCodeRepositoryImpl: QRCodeInterface {
  
  public init() {}
  
  public func createQRCode(userID: Int) async throws -> String {
    return ""
  }
  
  public func generateQRCode(from string: String) async -> Image? {
    return nil
  }
  
  public func qrValidateCheck(
    from code: String
  ) async throws -> QRValidateEntity {
    return QRValidateEntity(
      isSuccess: true,
      code: code,
      message: "QR 인증 완료",
      detail: "출석 체크가 완료되었습니다."
    )
  }
}
