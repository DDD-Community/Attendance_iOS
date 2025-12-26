//
//  DefaultQRCodeRepositoryImpl.swift
//  Repository
//
//  Created by Wonji Suh  on 7/23/25.
//

import SwiftUI

import DomainInterface
import Model

final public class DefaultQRCodeRepositoryImpl: QRCodeInterface {
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

