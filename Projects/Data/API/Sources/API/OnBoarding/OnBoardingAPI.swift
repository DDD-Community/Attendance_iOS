//
//  OnBoardingAPI.swift
//  API
//
//  Created by Wonji Suh  on 12/30/25.
//

import Foundation

public enum OnBoardingAPI: String, CaseIterable {
  case verifyCode
  case teams
  case jobs
  case mangerRole
  
  public var description: String {
    switch self {
      case .verifyCode:
        return "verify-code"
        
      case .teams:
        return "teams"
        
      case .jobs:
        return "jobs"
        
      case .mangerRole:
        return "manager-roles"
    }
  }
}
