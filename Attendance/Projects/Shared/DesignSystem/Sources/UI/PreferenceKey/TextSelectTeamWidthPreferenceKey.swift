//
//  TextSelectTeamWidthPreferenceKey.swift
//  DesignSystem
//
//  Created by Wonji Suh  on 1/27/25.
//

import Model
import SwiftUI


public struct TextWidthPreferenceKey: PreferenceKey {
  public static var defaultValue: [SelectTeam: CGFloat] = [:]
  public static func reduce(value: inout [SelectTeam: CGFloat], nextValue: () -> [SelectTeam: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}
