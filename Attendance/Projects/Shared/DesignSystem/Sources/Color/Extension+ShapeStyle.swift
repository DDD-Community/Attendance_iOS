//
//  Extension+ShapeStyle.swift
//  DesignSystem
//
//  Created by Wonji Suh  on 12/5/24.
//

import SwiftUI

public extension ShapeStyle where Self == Color {
  
  // MARK: - Static Basic
  
  static var staticWhite: Color { .init(hex: "FFFFFF") }
  static var staticBlack: Color { .init(hex: "0C0E0F") }
  
  // MARK: - Static Text
  
  static var textPrimary: Color { .init(hex: "FFFFFF") }
  static var textSecondary: Color { .init(hex: "EAEAEA") }
  static var textInactive: Color { .init(hex: "70737C47").opacity(0.28) }
  
  // MARK: - Static Background
  
  static var backGroundPrimary: Color { .init(hex: "0C0E0F") }
  static var backgroundInverse: Color { .init(hex: "FFFFFF") }
  
  // MARK: - Static Border
  
  static var borderInactive: Color { .init(hex: "C6C6C6") }
  static var borderDisabled: Color { .init(hex: "323537") }
  static var borderInverse: Color { .init(hex: "202325") }
  
  // MARK: - Static Status
  
  static var statusFocus: Color { .init(hex: "0D82F9") }
  static var statusCautionary: Color { .init(hex: "FD5D08") }
  static var statusError: Color { .init(hex: "FD1008") }
  
  // MARK: - Primitives
  
  static var grayBlack: Color { .init(hex: "1A1A1A") }
  static var gray80: Color { .init(hex: "323537") }
  static var gray60: Color { .init(hex: "6F6F6F") }
  static var gray40: Color { .init(hex: "A8A8A8") }
  static var gray90: Color { .init(hex: "202325") }
  static var grayError: Color { .init(hex: "FF5050") }
  static var grayWhite: Color { .init(hex: "FFFFFF") }
  static var grayPrimary: Color { .init(hex: "0099FF") }
  
  // MARK: - Surface
  
  static var surfaceBackground: Color { .init(hex: "1A1A1A") }
  static var surfaceElevated: Color { .init(hex: "4D4D4D").opacity(0.4) }
  static var surfaceNormal: Color { .init(hex: "FFFFFF") }
  static var surfaceAccent: Color { .init(hex: "E6E6E6") }
  static var surfaceDisable: Color { .init(hex: "808080") }
  static var surfaceEnable: Color { .init(hex: "0099FF") }
  static var surfaceError: Color { .init(hex: "FF5050").opacity(0.2) }
  
  // MARK: - TextIcon
  
  static var onBackground: Color { .init(hex: "FFFFFF") }
  static var onNormal: Color { .init(hex: "1A1A1A") }
  static var onDisabled: Color { .init(hex: "4D4D4D").opacity(0.4) }
  static var onError: Color { .init(hex: "FF5050") }
  
  // MARK: - NatureBlue
  
  static var blue10: Color { .init(hex: "F5F8FF") }
  static var blue20: Color { .init(hex: "E1EAFF") }
  static var blue30: Color { .init(hex: "C1D3FF") }
  static var blue40: Color { .init(hex: "0D82F9") }
  static var blue50: Color { .init(hex: "0c75e0") }
  static var blue60: Color { .init(hex: "0a68c7") }
  static var blue70: Color { .init(hex: "0a62bb") }
  static var blue80: Color { .init(hex: "084E95") }
  static var blue90: Color { .init(hex: "063A70") }
  static var blue100: Color { .init(hex: "052E57") }
  
  // MARK: - NatureRed
  
  static var red10: Color { .init(hex: "ffe7e6") }
  static var red20: Color { .init(hex: "ffdbda") }
  static var red30: Color { .init(hex: "feb5b2") }
  static var red40: Color { .init(hex: "fd1008") }
  static var red50: Color { .init(hex: "e40e07") }
  static var red60: Color { .init(hex: "ca0d06") }
  static var red70: Color { .init(hex: "be0c06") }
  static var red80: Color { .init(hex: "980a05") }
  static var red90: Color { .init(hex: "720704") }
  static var red100: Color { .init(hex: "590603") }
  
  static var basicBlack: Color { .init(hex: "1A1A1A") }
  static var gray200: Color { .init(hex: "E6E6E6") }
  static var gray300: Color { .init(hex: "8F8F8F") }
  static var gray400: Color { .init(hex: "B3B3B3") }
  static var gray600: Color { .init(hex: "808080") }
  static var gray800: Color { .init(hex: "4D4D4D") }
  
  static var error: Color { .init(hex: "FF5050") }
  static var basicBlue: Color { .init(hex: "0099FF") }
  
  static var basicBlackDimmed: Color { .init(hex: "#333332").opacity(0.7) }
}
