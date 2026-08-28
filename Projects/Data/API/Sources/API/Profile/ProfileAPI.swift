//
//  ProfileAPI.swift
//  API
//
//  Created by DDD on 5/8/25.
//

import Foundation

public enum ProfileAPI: String , CaseIterable {
  case getUser
  case getAdmin
  case editUser

  
  
  public var profileDescription: String {
    switch self {
      case .getUser:
        return ""

      case .getAdmin:
        return "/me"

      case .editUser:
        return "/me"
    }
  }
  
}

