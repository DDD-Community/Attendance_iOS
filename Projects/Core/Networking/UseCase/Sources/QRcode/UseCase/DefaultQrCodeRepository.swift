//
//  DefaultQrCodeRepository.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/11/24.
//

import SwiftUI

import Model

final public class DefaultQrCodeRepository: QrCodeRepositoryProtcol {
  public init() {}
  
  public func generateQRCode(from string: String) async -> Image? {
    return nil
  }
  
  public func qrAttendanceCheck(
    from code: String
  ) async throws -> QRValidateModel? {
    return nil
  }
  
}
