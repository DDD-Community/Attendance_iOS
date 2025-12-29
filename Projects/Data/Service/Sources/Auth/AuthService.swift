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
  case login(email: String)
  case loginOAuth(body: OAuthLoginRequest)

}


extension AuthService: BaseTargetType {
  public typealias Domain = AttendanceDomain

  public var domain: AttendanceDomain {
    return .auth
  }

  public var urlPath: String {
    switch self {
    case .login:
      return AuthAPI.login.authDescription

      case .loginOAuth:
        return AuthAPI.login.authDescription

    }
  }

  public var error: [Int : AsyncMoya.NetworkError]? {
    return  nil
  }

  public var method: Moya.Method {
    switch self {
      case .login, .loginOAuth:
      return .post
    }
  }

  public var parameters: [String : Any]? {
    switch self {
    case .login(
      let email):
      let parameters: [String: Any] = [
        "email": email,
      ]
      return parameters

      case .loginOAuth(let body):
        return body.toDictionary

    }
  }

  public var headers: [String : String]? {
    switch self {
    default:
      return APIHeader.notAccessTokenHeader
    }
  }
}
