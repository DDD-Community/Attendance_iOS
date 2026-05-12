//
//  TextSelectTeamWidthPreferenceKey.swift
//  DesignSystem
//
//  Created by Wonji Suh  on 1/27/25.
//

import Entity
import SwiftUI

public struct TextWidthPreferenceKey: PreferenceKey {
    public static var defaultValue: [SelectTeams: CGFloat] = [:]
    public static func reduce(value: inout [SelectTeams: CGFloat], nextValue: () -> [SelectTeams: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}
