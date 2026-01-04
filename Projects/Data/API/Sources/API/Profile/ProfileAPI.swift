//
//  ProfileAPI.swift
//  API
//
//  Created by Wonji Suh  on 5/8/25.
//

import Foundation

public enum ProfileAPI: String , CaseIterable {
  case getUser

  
  
  public var profileDescription: String {
    switch self {
      case .getUser:
        return "/me"
    }
  }
  
}

