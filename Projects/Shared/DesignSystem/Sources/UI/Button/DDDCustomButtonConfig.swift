//
//  DDDCustomButtonConfig.swift
//  DesignSystem
//
//  Created by Wonji Suh  on 11/2/24.
//

import SwiftUI

public class DDDCustomButtonConfig {
  public let cornerRadius: CGFloat
  public let enableFontColor: Color
  public let enableBackgroundColor:Color
  public let frameHeight: CGFloat
  public let disableFontColor: Color
  public let disableBackgroundColor:Color
  
  public init(
    cornerRadius: CGFloat,
    enableFontColor: Color,
    enableBackgroundColor: Color,
    frameHeight: CGFloat,
    disableFontColor: Color,
    disableBackgroundColor: Color
  ) {
    self.cornerRadius = cornerRadius
    self.enableFontColor = enableFontColor
    self.enableBackgroundColor = enableBackgroundColor
    self.frameHeight = frameHeight
    self.disableFontColor = disableFontColor
    self.disableBackgroundColor = disableBackgroundColor
  }
}
