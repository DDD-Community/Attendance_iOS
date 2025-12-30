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
  case jobs
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

      case .jobs:
        return OnBoardingAPI.jobs.description
    }
  }
  
  public var error: [Int : AsyncMoya.NetworkError]? {
    return nil
  }
  
  public var parameters: [String : Any]? {
    switch self {
      case .verifyCode(let code):
        return code.toDictionary(key: "code")

      case .jobs:
        return nil
    }
  }
  
  public var method: Moya.Method {
    switch self {
      case .verifyCode, .jobs:
        return .get
    }
  }
}
