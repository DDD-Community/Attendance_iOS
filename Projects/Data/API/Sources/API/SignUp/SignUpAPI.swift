//
//  SignUpAPI.swift
//  API
//
//  Created by DDD on 5/7/25.
//

import Foundation

public enum SignUpAPI: String , CaseIterable {
  case signUpUser

  public var signUpDescription: String {
    switch self {
      case .signUpUser:
        return ""
    }
  }
  
}

