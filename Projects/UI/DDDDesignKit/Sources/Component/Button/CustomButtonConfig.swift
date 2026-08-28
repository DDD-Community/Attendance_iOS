//
//  CustomButtonConfig.swift
//  DDDDesignKit
//
//  Created by Wonji Suh  on 11/2/24.
//

import SwiftUI

public class CustomButtonConfig: DDDCustomButtonConfig {
  public static func create() -> DDDCustomButtonConfig {
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

  public static func createVoteButton() -> DDDCustomButtonConfig {
    let config = DDDCustomButtonConfig(
      cornerRadius: 10,
      enableFontColor: .grayWhite,
      enableBackgroundColor: .blue45,
      frameHeight: 52,
      disableFontColor: .grayWhite,
      disableBackgroundColor: .blue20
    )
    return config
  }

  public static func createEndVoteButton() -> DDDCustomButtonConfig {
    let config = DDDCustomButtonConfig(
      cornerRadius: 10,
      enableFontColor: .grayWhite,
      enableBackgroundColor: .statusErrorText,
      frameHeight: 52,
      disableFontColor: .grayWhite,
      disableBackgroundColor: .gray80
    )
    return config
  }

  public static func createDateButton() -> DDDCustomButtonConfig {
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
