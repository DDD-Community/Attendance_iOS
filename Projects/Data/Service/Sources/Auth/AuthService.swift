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
  case login(body: OAuthLoginRequest)
  case refresh(refreshToken: String)
  case withdraw(token: String)

}

extension AuthService: BaseTargetType {
  public typealias Domain = AttendanceDomain

  public var domain: AttendanceDomain {
    switch self {
      case .login, .refresh:
        return .auth
      case .withdraw:
        return .user
    }
  }

  public var urlPath: String {
    switch self {
      case .login:
        return AuthAPI.login.description

      case .refresh:
        return AuthAPI.refresh.description

      case .withdraw:
        return AuthAPI.withDraw.description
    }
  }

  public var error: [Int : AsyncMoya.NetworkError]? {
    return  nil
  }

  public var method: Moya.Method {
    switch self {
      case .login, .refresh:
        return .post
      case .withdraw:
        return .delete
    }
  }

  public var parameters: [String : Any]? {
    switch self {
      case .login(let body):
        return body.toDictionary

      case .refresh(let refreshToken):
        return refreshToken.toDictionary(key: "refreshToken")

      case .withdraw(let token):
        return token.toDictionary(key: "token")
    }
  }

  public var headers: [String : String]? {
    switch self {
      case .refresh, .withdraw:
        return APIHeader.baseHeader
      default:
        return APIHeader.notAccessTokenHeader
    }
  }
}
