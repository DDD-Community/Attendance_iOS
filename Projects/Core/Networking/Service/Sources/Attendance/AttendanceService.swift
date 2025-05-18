//
//  AttendanceService.swift
//  Service
//
//  Created by Wonji Suh  on 5/10/25.
//

import Foundation

import API
import Foundations

import AsyncMoya

public enum AttendanceService {
  case fetchCount(userID: Int)
}

extension AttendanceService: BaseTargetType {
  public var domain: AttendanceDomain {
    return .attendance
  }

  public var urlPath: String {
    switch self {
    case .fetchCount:
      return AttandanceAPI.fetchCount.attandanceDescription
    }
  }

  public var error: [Int : NetworkError]? {
    return nil
  }

  public var method: Moya.Method {
    switch self {
    case .fetchCount:
      return .get
    }
  }

  public var parameters: [String : Any]? {
    switch self {
    case .fetchCount(let userID):
      return ["user_id": userID]
    }
  }

  public var headers: [String : String]? {
    switch self {
    case .fetchCount:
      return APIHeader.baseHeader
    }
  }
}
