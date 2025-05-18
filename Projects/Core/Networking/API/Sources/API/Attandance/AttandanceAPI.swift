//
//  AttandanceAPI.swift
//  API
//
//  Created by Wonji Suh  on 5/10/25.
//

import Foundation

public enum AttandanceAPI: String, CaseIterable {
  case fetchCount

  public var attandanceDescription: String {
    switch self {
    case .fetchCount:
      return "count/"
    }
  }
}
