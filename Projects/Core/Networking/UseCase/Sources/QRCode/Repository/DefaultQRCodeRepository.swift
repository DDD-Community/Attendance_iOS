//
//  DefaultQRCodeRepository.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/11/24.
//

import SwiftUI

import Model

final public class DefaultQRCodeRepository: QRCodeRepositoryProtocol {
  public init() {}

  public func createQRCode() async throws -> String {
    return ""
  }

  public func generateQRCode(from string: String) async -> Image? {
    return nil
  }
  
  public func qrAttendanceCheck(
    from code: String
  ) async throws -> QRValidateModel? {
    return nil
  }
}
