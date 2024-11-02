//
//  Colors.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/6/24.
//

import Foundation
import SwiftUI

public extension Color {
  
  static let backGround = Color(hex: "0C0E0F")
  
  //MARK: - Primitives
  static let grayBlack = Color(hex: "1A1A1A")
  static let gray80 = Color(hex: "323537")
  static let gray60 = Color(hex: "6F6F6F")
  static let gray40 = Color(hex: "A8A8A8")
  static let grayError = Color(hex: "FF5050")
  static let grayWhite = Color(hex: "FFFFFF")
  static let grayPrimary = Color(hex: "0099FF")
  
  
  //MARK: - Surface
  static let surfaceBackground = Color(hex: "1A1A1A")
  static let surfaceElevated = Color(hex: "4D4D4D").opacity(0.4)
  static let surfaceNormal = Color(hex: "FFFFFF")
  static let surfaceAccent = Color(hex: "E6E6E6")
  static let surfaceDisable = Color(hex: "808080")
  static let surfaceEnable = Color(hex: "0099FF")
  static let surfaceError = Color(hex: "FF5050").opacity(0.2)
  
  
  //MARK: - TextIcon
  static let onBackground = Color(hex: "FFFFFF")
  static let onNormal = Color(hex: "1A1A1A")
  static let onDisabled = Color(hex: "4D4D4D").opacity(0.4)
  static let onError = Color(hex: "FF5050")
  
    static let basicBlack = Color(hex: "1A1A1A")
    static let gray200 = Color(hex: "E6E6E6")
    static let gray300 = Color(hex: "8F8F8F")
    static let gray400 = Color(hex: "B3B3B3")
    static let gray600 = Color(hex: "808080")
    static let gray800 = Color(hex: "4D4D4D")
    static let basicWhite = Color(hex: "FFFFFF")
    static let error = Color(hex: "FF5050")
    static let basicBlue = Color(hex: "0099FF")
    
    static let basicBlackDimmed = Color(hex: "#333332").opacity(0.7)
}
