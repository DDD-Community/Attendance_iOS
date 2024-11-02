//
//  DDDCustomButtonConfig.swift
//  DesignSystem
//
//  Created by Wonji Suh  on 11/2/24.
//

import Foundation
import SwiftUI

public class DDDCustomButtonConfig {
    var cornerRadius: CGFloat
    var enableFontColor: Color
    var enableBackgroundColor:Color
    var frameHeight: CGFloat
    var disableFontColor: Color
    var disableBackgroundColor:Color
    
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
