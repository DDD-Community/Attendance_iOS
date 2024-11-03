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
  static let gray90 = Color(hex: "202325")
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
  
  //MARK: - netureBlue
  static let blue10 = Color(hex: "F5F8FF")
  static let blue20 = Color(hex: "E1EAFF")
  static let blue30 = Color(hex: "C1D3FF")
  static let blue40 = Color(hex: "0D82F9")
  static let blue50 = Color(hex: "0c75e0")
  static let blue60 = Color(hex: "0a68c7")
  static let blue70 = Color(hex: "0a62bb")
  static let blue80 = Color(hex: "084E95")
  static let blue90 = Color(hex: "063A70")
  static let blue100 = Color(hex: "052E57")
  
  
  
  //MARK: - netureRed
  static let red10 = Color(hex: "ffe7e6")
  static let red20 = Color(hex: "ffdbda")
  static let red30 = Color(hex: "feb5b2")
  static let red40 = Color(hex: "fd1008")
  static let red50 = Color(hex: "e40e07")
  static let red60 = Color(hex: "ca0d06")
  static let red70 = Color(hex: "be0c06")
  static let red80 = Color(hex: "980a05")
  static let red90 = Color(hex: "720704")
  static let red100 = Color(hex: "590603")
  
  //MARK: - border
  static let borderError = Color(hex: "FD1008")
  static let borderInactive = Color(hex: "C6C6C6")
  
  //MARK: - text
  static let textInactive = Color(hex: "C6C6C6")
  
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
