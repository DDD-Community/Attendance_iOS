//
//  QRCodeRepositoryProtocol.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/11/24.
//

import SwiftUI

public protocol QRCodeRepositoryProtocol {
  func createQRCode() async throws -> String
  func generateQRCode(from string: String) async -> Image?
  func qrAttendanceCheck(from code: String) async throws -> QRValidateModel?
}
