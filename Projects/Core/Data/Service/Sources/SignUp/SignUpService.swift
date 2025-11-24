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
    email: String,
    password1: String,
    password2: String
  )
  case verifyInviteCode(inviteCode: String)
  case checkEmail(email: String)
}

extension SignUpService: BaseTargetType {
  public typealias Domain = AttendanceDomain

  public var domain: AttendanceDomain {
    switch self {
    case .registerAccount, .checkEmail:
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
      
    case .checkEmail:
      return SignUpAPI.checkEmail.signUpDescription
    }
  }
  
  public var method: Moya.Method {
    switch self {
    case .registerAccount, .verifyInviteCode, .checkEmail:
      return .post
      
    }
  }
  
  public var error: [Int : AsyncMoya.NetworkError]? {
    return  nil
  }

  public var parameters: [String : Any]? {
    switch self {
    case .registerAccount(
      let email,
      let password1,
      let password2
    ):
      let parameters: [String: Any] = [
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
      
    case .checkEmail(let email):
      let parameters: [String: Any] = [
        "email": email
      ]
      return parameters
    }
  }
}

