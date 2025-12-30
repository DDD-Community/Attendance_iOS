//
//  OnBoardingService.swift
//  Service
//
//  Created by Wonji Suh  on 12/30/25.
//

import Foundation

import API

import AsyncMoya

public enum OnBoardingService {
  case verifyCode(code : String)
}


extension OnBoardingService: BaseTargetType {
  public typealias Domain = AttendanceDomain

  public var domain: AttendanceDomain {
    return .onboarding
  }

  public var urlPath: String {
    switch self {
      case .verifyCode:
        return OnBoardingAPI.verifyCode.description
    }
  }
  
  public var error: [Int : AsyncMoya.NetworkError]? {
    return nil
  }
  
  public var parameters: [String : Any]? {
    switch self {
      case .verifyCode(let code):
        return code.toDictionary(key: "code")
    }
  }
  
  public var method: Moya.Method {
    switch self {
      case .verifyCode:
        return .get
    }
  }
}
