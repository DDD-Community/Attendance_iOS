//
//  PretendardFontFamily.swift
//  DDDDesignKit
//
//  Created by DDD on 7/13/24.
//

import Foundation

public enum PretendardFontFamily {
  case Black
  case Bold
  case ExtraBold
  case ExtraLight
  case Light
  case Medium
  case Regular
  case SemiBold
  case Thin

  public static func registerFonts() {
    var registeredPaths = Set<String>()
    for font in DDDDesignKitFontFamily.allCustomFonts
    where registeredPaths.insert(font.path).inserted {
      font.register()
    }
  }
}
