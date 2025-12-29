//
//  SocialType.swift
//  Entity
//
//  Created by Wonji Suh  on 12/29/25.
//

import Foundation

public enum SocialType: String, CaseIterable, Identifiable, Hashable {
  case apple
  case google

  public var id: String { rawValue }

  var description: String {
    switch self {
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
    }
  }
}
