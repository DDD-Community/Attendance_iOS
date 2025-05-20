//
//  QrCodeRepositoryProtcol.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/11/24.
//

import SwiftUI

import Model

public protocol QrCodeRepositoryProtcol {
  func generateQRCode(from string: String) async -> Image?
  func qrAttendanceCheck(from code: String) async throws -> QRValidateModel?
}
