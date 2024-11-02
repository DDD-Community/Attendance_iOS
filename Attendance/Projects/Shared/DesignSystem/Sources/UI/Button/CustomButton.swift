//
//  CustomButton.swift
//  DesignSystem
//
//  Created by Wonji Suh  on 11/2/24.
//

import SwiftUI

public struct CustomButton: View {
    let action: () -> Void
    let title: String
  let config: DDDCustomButtonConfig
    var isEnable: Bool = false
    
    public init(
        action: @escaping () -> Void,
        title:String,
        config:DDDCustomButtonConfig,
        isEnable: Bool = false
    ) {
        self.title = title
        self.config = config
        self.action = action
        self.isEnable = isEnable
    }
    
    public var body: some View {
        RoundedRectangle(cornerRadius: config.cornerRadius)
            .fill(isEnable ? config.enableBackgroundColor : config.disableBackgroundColor)
            .frame(height: config.frameHeight)
            .clipShape(Capsule())
            .overlay {
                Text(title)
                    .pretendardFont(family: .SemiBold, size: 20)
                    .foregroundColor(isEnable ? config.enableFontColor : config.disableFontColor)
            }
            .onTapGesture {
                action()
            }
            .disabled(!isEnable)
            
    }
}
