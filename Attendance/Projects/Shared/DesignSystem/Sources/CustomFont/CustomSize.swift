//
//  CustomSize.swift
//  DesignSystem
//
//  Created by Wonji Suh  on 11/2/24.
//

import Foundation

public enum CustomSizeFont {
  case tilte1NormalBold
  case tilte1NormalMedium
  case title2NormalBold
  case title2NormalMedium
  case title3NormalBold
  case title3NormalMedium
  case title3NormalRegular
  case body1NormalBold
  case body1NormalMedium
  case body1NormalRegular
  case body2NormalBold
  case body2NormalMedium
  case body2NormalRegular
  case body3NormalBold
  case body3NormalMedium
  case body3NormalRegular
  case body4NormalRegular
  case body4NormalMedium
  
  public var size: CGFloat {
    switch self {
    case .tilte1NormalBold:
      return 28
    case .tilte1NormalMedium:
      return 28
    case .title2NormalBold:
      return 24
    case .title2NormalMedium:
      return 24
    case .title3NormalBold:
      return 20
    case .title3NormalMedium:
      return 20
    case .title3NormalRegular:
      return 20
    case .body1NormalBold:
      return 18
    case .body1NormalMedium:
      return 18
    case .body1NormalRegular:
      return 18
    case .body2NormalBold:
      return 16
    case .body2NormalMedium:
      return 16
    case .body2NormalRegular:
      return 16
    case .body3NormalBold:
      return 14
    case .body3NormalMedium:
      return 14
    case .body3NormalRegular:
      return 14
    case .body4NormalRegular:
      return 12
    case .body4NormalMedium:
      return 12
    }
  }
  
  public var fontFamily: PretendardFontFamily {
    switch self {
    case .tilte1NormalBold:
      return .Bold
    case .tilte1NormalMedium:
      return .Medium
    case .title2NormalBold:
      return .Bold
    case .title2NormalMedium:
      return .Medium
    case .title3NormalBold:
      return .Bold
    case .title3NormalMedium:
      return .Medium
    case .title3NormalRegular:
      return .Regular
    case .body1NormalBold:
      return .Bold
    case .body1NormalMedium:
      return .Medium
    case .body1NormalRegular:
      return .Regular
    case .body2NormalBold:
      return .Bold
    case .body2NormalMedium:
      return .Medium
    case .body2NormalRegular:
      return .Regular
    case .body3NormalBold:
      return .Bold
    case .body3NormalMedium:
      return .Medium
    case .body3NormalRegular:
      return .Regular
    case .body4NormalRegular:
      return .Regular
    case .body4NormalMedium:
      return .Medium
    }
  }
}

