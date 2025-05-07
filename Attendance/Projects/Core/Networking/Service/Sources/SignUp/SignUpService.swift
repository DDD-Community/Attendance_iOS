//
//  SignUpService.swift
//  Service
//
//  Created by Wonji Suh  on 5/7/25.
//

import Foundation

import API
import Foundations

import AsyncMoya

 public enum SignUpService {
  // Mark : - 회원가입
  case registerAccount(
    username: String,
    email: String,
    password1: String,
    password2: String
  )
   case verifyInviteCode(inviteCode: String)
}

extension SignUpService: BaseTargetType {
  public var domain: AttandanceDomain {
    switch self {
    case .registerAccount:
      return .auth
      
    case .verifyInviteCode:
      return .invite
      
    }
  }
  
  public var urlPath: String {
    switch self {
    case .registerAccount:
      return SignUpAPI.registerAccount.signUpDescription
      
    case .verifyInviteCode:
      return SignUpAPI.verifyInviteCode.signUpDescription
    }
  }
  
  public var method: Moya.Method {
    switch self {
    case .registerAccount, .verifyInviteCode:
      return .post
      
    }
  }

  public var error: [Int : Foundations.NetworkError]? {
    return nil
  }
  
  public var parameters: [String : Any]? {
    switch self {
    case .registerAccount(
      let username,
      let email,
      let password1,
      let password2
    ):
      
      let parameters: [String: Any] = [
        "username" : username,
        "email" : email,
        "password1" : password1,
        "password2" : password2
      ]
      return parameters
      
    case .verifyInviteCode(let inviteCode):
      let parameters: [String: Any] = [
        "invite_code" : inviteCode
      ]
      return parameters
    }
  }
}
