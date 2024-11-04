//
//  Extension+AttendanceDTO.swift
//  DesignSystem
//
//  Created by Wonji Suh  on 11/4/24.
//

import Model
import SwiftUI

public extension AttendanceDTO {
    func backgroundColor(
        isBackground: Bool = false,
        isNameColor: Bool = false,
        isGenerationColor: Bool = false,
        isRoletTypeColor: Bool = false
    ) -> Color {
        switch self.status {
        case .present:
            switch (isBackground, isNameColor, isGenerationColor, isRoletTypeColor) {
            case (true, _, _, _):
                return .basicWhite
            case (_, true, _, _):
                return .basicBlack
            case (_, _, true, _):
                return .gray600
            case (_, _, _, true):
                return .basicBlack
            default:
                return .gray800 // Default color if none match
            }
        case .late:
            switch (isBackground, isNameColor, isGenerationColor, isRoletTypeColor) {
            case (true, _, _, _):
                return .gray800
            case (_, true, _, _):
                return .gray600
            case (_, _, true, _):
                return .gray600
            case (_, _, _, true):
                return .gray600
            default:
                return .gray800
            }
        case .run:
            switch (isBackground, isNameColor, isGenerationColor, isRoletTypeColor) {
            case (true, _, _, _):
                return .gray800
            case (_, true, _, _):
                return .gray600
            case (_, _, true, _):
                return .gray600
            case (_, _, _, true):
                return .gray600
            default:
                return .gray800
            }
            
        case nil:
            switch (isBackground, isNameColor, isGenerationColor, isRoletTypeColor) {
            case (true, _, _, _):
                return .gray800
            case (_, true, _, _):
                return .gray600
            case (_, _, true, _):
                return .gray600
            case (_, _, _, true):
                return .gray600
            default:
                return .gray800
            }
            
        default:
            switch (isBackground, isNameColor, isGenerationColor, isRoletTypeColor) {
            case (true, _, _, _):
                return .gray800
            case (_, true, _, _):
                return .gray600
            case (_, _, true, _):
                return .gray600
            case (_, _, _, true):
                return .gray600
            default:
                return .gray800
            }
        }
    }
}
