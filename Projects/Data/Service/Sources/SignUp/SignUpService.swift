//
//  SignUpService.swift
//  Service
//
//  Created by DDD on 5/7/25.
//

import Foundation

import API
import Foundations

import AsyncMoya

public enum SignUpService {
  // Mark : - 회원가입
  case signUpUser(body: SignUpUserRequestDTO)
}

extension SignUpService: BaseTargetType {
  public typealias Domain = AttendanceDomain
  
  public var domain: AttendanceDomain {
    switch self {
      case .signUpUser:
        return .user
    }
  }
  
  public var urlPath: String {
    switch self {
      case .signUpUser:
        return SignUpAPI.signUpUser.signUpDescription
        
    }
  }
  
  public var method: Moya.Method {
    switch self {
      case .signUpUser:
        return .post
        
    }
  }
  
  public var error: [Int : AsyncMoya.NetworkError]? {
    return  nil
  }
  
  public var parameters: [String : Any]? {
    switch self {
      case .signUpUser(let body):
        return body.toDictionary
    }
  }
}
