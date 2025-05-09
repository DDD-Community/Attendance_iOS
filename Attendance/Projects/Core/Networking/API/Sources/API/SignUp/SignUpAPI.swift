//
//  SignUpAPI.swift
//  API
//
//  Created by Wonji Suh  on 5/7/25.
//

import Foundation

public enum SignUpAPI: String , CaseIterable {
  case registerAccount
  case verifyInviteCode
  case checkEmail
  
  
  public var signUpDescription: String {
    switch self {
    case .registerAccount:
      return "registration/"
      
    case .verifyInviteCode:
      return "validate/"
      
    case .checkEmail:
      return "check-email/"
    }
  }
  
}

