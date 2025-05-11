//
//  CustomButtonConfig.swift
//  DesignSystem
//
//  Created by Wonji Suh  on 11/2/24.
//

import SwiftUI

public class CustomButtonConfig: DDDCustomButtonConfig {
  static public func create() -> DDDCustomButtonConfig {
    let config = DDDCustomButtonConfig(
      cornerRadius: 30,
      enableFontColor: Color.grayWhite,
      enableBackgroundColor: Color.surfaceEnable,
      frameHeight: 48,
      disableFontColor: Color.grayWhite,
      disableBackgroundColor: Color.blue30
    )
    
    return config
  }
  
  static public func createDateButton() -> DDDCustomButtonConfig {
    let config = DDDCustomButtonConfig(
      cornerRadius: 30,
      enableFontColor: .grayWhite,
      enableBackgroundColor: .statusFocus,
      frameHeight: 58,
      disableFontColor: .grayWhite,
      disableBackgroundColor: .blue20
    )
    return config
  }
  
}
