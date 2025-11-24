//
//  QRCodeInterface.swift
//  DomainInterface
//
//  Created by Wonji Suh  on 7/23/25.
//

import Foundation
import SwiftUI

public protocol QRCodeInterface: Sendable {
  func createQRCode() async throws -> String
  func generateQRCode(from string: String) async -> Image?
  func qrAttendanceCheck(from code: String) async throws -> QRValidateModel?
}
