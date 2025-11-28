//
//  ProfileAPI.swift
//  API
//
//  Created by Wonji Suh  on 5/8/25.
//

import Foundation

public enum ProfileAPI: String , CaseIterable {
  case editProfile
  case getProfile
  
  
  
  public var profileDescription: String {
    switch self {
    case .editProfile:
      return "me/"
      
    case .getProfile:
      return "me/"
    }
  }
  
}

