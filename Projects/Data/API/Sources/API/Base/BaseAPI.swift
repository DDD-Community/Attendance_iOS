//
//  BaseAPI.swift
//  API
//
//  Created by Wonji Suh  on 4/8/25.
//

import Foundation
import AsyncMoya

public enum BaseAPI : String {
  case base
  
  public var apiDescription: String {
    switch self {
    case .base:
      return "https://\(Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String ?? "")"
    }
  }
}
