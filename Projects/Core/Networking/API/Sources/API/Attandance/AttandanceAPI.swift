//
//  AttandanceAPI.swift
//  API
//
//  Created by Wonji Suh  on 5/10/25.
//

import Foundation

public enum AttandanceAPI: String, CaseIterable {
  case getAttandances
   
  public var attandanceDescription: String {
    switch self {
    case .getAttandances:
      return ""
    }
  }
}
