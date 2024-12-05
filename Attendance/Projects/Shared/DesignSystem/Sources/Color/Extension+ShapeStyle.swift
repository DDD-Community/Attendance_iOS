//
//  Extension+ShapeStyle.swift
//  DesignSystem
//
//  Created by Wonji Suh  on 12/5/24.
//

import Foundation
import SwiftUI

public extension ShapeStyle where Self == Color {

    // MARK: - Static Basic
  
    static var staticWhite: Color { Color(hex: "FFFFFF") }
    static var staticBlack: Color { Color(hex: "0C0E0F") }
    
    // MARK: - Static Text
  
    static var textPrimary: Color { Color(hex: "FFFFFF") }
    static var textSecondary: Color { Color(hex: "EAEAEA") }
    static var textInactive: Color { Color(hex: "70737C47").opacity(0.28) }
    
    // MARK: - Static Background
  
    static var backGroundPrimary: Color { Color(hex: "0C0E0F") }
    static var backgroundInverse: Color { Color(hex: "FFFFFF") }
    
    // MARK: - Static Border
  
    static var borderInactive: Color { Color(hex: "C6C6C6") }
    static var borderDisabled: Color { Color(hex: "323537") }
    static var borderInverse: Color { Color(hex: "202325") }
    
    // MARK: - Static Status
  
    static var statusFocus: Color { Color(hex: "0D82F9") }
    static var statusCautionary: Color { Color(hex: "FD5D08") }
    static var statusError: Color { Color(hex: "FD1008") }
    
    // MARK: - Primitives
  
    static var grayBlack: Color { Color(hex: "1A1A1A") }
    static var gray80: Color { Color(hex: "323537") }
    static var gray60: Color { Color(hex: "6F6F6F") }
    static var gray40: Color { Color(hex: "A8A8A8") }
    static var gray90: Color { Color(hex: "202325") }
    static var grayError: Color { Color(hex: "FF5050") }
    static var grayWhite: Color { Color(hex: "FFFFFF") }
    static var grayPrimary: Color { Color(hex: "0099FF") }
    
    // MARK: - Surface
  
    static var surfaceBackground: Color { Color(hex: "1A1A1A") }
    static var surfaceElevated: Color { Color(hex: "4D4D4D").opacity(0.4) }
    static var surfaceNormal: Color { Color(hex: "FFFFFF") }
    static var surfaceAccent: Color { Color(hex: "E6E6E6") }
    static var surfaceDisable: Color { Color(hex: "808080") }
    static var surfaceEnable: Color { Color(hex: "0099FF") }
    static var surfaceError: Color { Color(hex: "FF5050").opacity(0.2) }
    
    // MARK: - TextIcon
  
    static var onBackground: Color { Color(hex: "FFFFFF") }
    static var onNormal: Color { Color(hex: "1A1A1A") }
    static var onDisabled: Color { Color(hex: "4D4D4D").opacity(0.4) }
    static var onError: Color { Color(hex: "FF5050") }
    
    // MARK: - NatureBlue
  
    static var blue10: Color { Color(hex: "F5F8FF") }
    static var blue20: Color { Color(hex: "E1EAFF") }
    static var blue30: Color { Color(hex: "C1D3FF") }
    static var blue40: Color { Color(hex: "0D82F9") }
    static var blue50: Color { Color(hex: "0c75e0") }
    static var blue60: Color { Color(hex: "0a68c7") }
    static var blue70: Color { Color(hex: "0a62bb") }
    static var blue80: Color { Color(hex: "084E95") }
    static var blue90: Color { Color(hex: "063A70") }
    static var blue100: Color { Color(hex: "052E57") }
    
    // MARK: - NatureRed
  
    static var red10: Color { Color(hex: "ffe7e6") }
    static var red20: Color { Color(hex: "ffdbda") }
    static var red30: Color { Color(hex: "feb5b2") }
    static var red40: Color { Color(hex: "fd1008") }
    static var red50: Color { Color(hex: "e40e07") }
    static var red60: Color { Color(hex: "ca0d06") }
    static var red70: Color { Color(hex: "be0c06") }
    static var red80: Color { Color(hex: "980a05") }
    static var red90: Color { Color(hex: "720704") }
    static var red100: Color { Color(hex: "590603") }
    
    static var basicBlack: Color { Color(hex: "1A1A1A") }
    static var gray200: Color { Color(hex: "E6E6E6") }
    static var gray300: Color { Color(hex: "8F8F8F") }
    static var gray400: Color { Color(hex: "B3B3B3") }
    static var gray600: Color { Color(hex: "808080") }
    static var gray800: Color { Color(hex: "4D4D4D") }
    
    static var error: Color { Color(hex: "FF5050") }
    static var basicBlue: Color { Color(hex: "0099FF") }
    
    static var basicBlackDimmed: Color { Color(hex: "#333332").opacity(0.7) }
}
