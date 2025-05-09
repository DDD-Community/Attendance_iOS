//
//  SceduleAPI.swift
//  API
//
//  Created by Wonji Suh  on 5/9/25.
//

import Foundation

public enum SceduleAPI: String , CaseIterable {
  case getScedule
  
  public var sceduleDescription: String {
    switch self {
    case .getScedule:
      return ""
    }
  }
}
