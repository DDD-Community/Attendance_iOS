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
            disableBackgroundColor: Color.onDisabled
        )
        
        return config
    }
}
