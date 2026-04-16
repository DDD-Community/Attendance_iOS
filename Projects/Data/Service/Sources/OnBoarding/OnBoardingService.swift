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
  case teams(generationId: Int)
  case mangerRole
}


extension OnBoardingService: BaseTargetType  {
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

      case .teams:
        return OnBoardingAPI.teams.description

      case .mangerRole:
        return OnBoardingAPI.mangerRole.description
    }
  }

  public var error: [Int : AsyncMoya.NetworkError]? {
    return nil
  }

  public var parameters: [String : Any]? {
    switch self {
      case .verifyCode(let code):
        return code.toDictionary(key: "code")

      case .jobs, .mangerRole:
        return nil

      case .teams(let generationId):
        return generationId.toDictionary(key: "generationId")
    }
  }

  public var method: Moya.Method {
    switch self {
      case .verifyCode, .jobs, .teams, .mangerRole:
        return .get
    }
  }
}
