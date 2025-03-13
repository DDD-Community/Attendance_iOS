//
//  QrCodeUseCaseProtocol.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/11/24.
//

import SwiftUI

public protocol QrCodeUseCaseProtocol {
  func generateQRCode(from string: String) async -> Image?
}
