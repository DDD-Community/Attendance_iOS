//
//  AuthService.swift
//  Service
//
//  Created by Wonji Suh  on 5/9/25.
//

import Foundation

import API
import Foundations

import AsyncMoya

public enum AuthService {
  case login(email: String, password: String)
  case sessionToJwt(token: String)
}


extension AuthService: BaseTargetType {
  public var domain: Foundations.AttandanceDomain {
    return .auth
  }
  
  public var urlPath: String {
    switch self {
    case .login:
      return AuthAPI.login.authDescription
      
    case .sessionToJwt:
      return AuthAPI.sessionToJwt.authDescription
    }
  }
  
  public var error: [Int : Foundations.NetworkError]? {
    return nil
  }
  
  public var method: Moya.Method {
    switch self {
    case .login:
      return .post
      
    case .sessionToJwt:
      return .get
    }
  }
  
  public var parameters: [String : Any]? {
    switch self {
    case .login(
      let email,
      let password):
      let parameters: [String: Any] = [
        "email": email,
        "password": password
      ]
      return parameters
      
    case .sessionToJwt(let token):
      let parameters: [String: Any] = [
        "token": token
      ]
      return parameters
    }
  }
}
