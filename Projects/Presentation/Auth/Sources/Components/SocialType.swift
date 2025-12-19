//
//  SocialType.swift
//  Auth
//
//  Created by Wonji Suh  on 12/19/25.
//

import Foundation


public enum SocialType: String, CaseIterable, Identifiable, Hashable {
    case none
    case apple
    case google

    public var id: String { rawValue }

    var description: String {
        switch self {
            case .none:
                return "email"
            case .apple:
                return "Apple"
            case .google:
                return "Google"

        }
    }


    public var image: String {
        switch self {
            case .apple:
                return "apple.logo"
            case .google:
                return "google"
            case .none:
                return ""
        }
    }
}
