//
//  AuthAPI.swift
//  API
//
//  Created by Wonji Suh  on 5/9/25.
//

import Foundation

public enum AuthAPI: String, CaseIterable {
  case login
  case refresh

  public var description: String {
    switch self {
      case .login:
        return "login"
      case .refresh:
        return "refresh"
    }
  }
}
