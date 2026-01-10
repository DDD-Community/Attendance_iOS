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
  case adminAttendanceCount(scheduleId: Int)
}

extension AttendanceService: BaseTargetType {
  public typealias Domain = AttendanceDomain

  public var domain: AttendanceDomain {
    switch self {
      case .adminAttendanceCount:
        return .admin
    }
  }

  public var urlPath: String {
    switch self {
    case .adminAttendanceCount(let scheduleId):
      return AttendanceAPI.adminAttendanceCount(scheduleId: scheduleId).description

    }
  }

  public var error: [Int : AsyncMoya.NetworkError]? {
    return  nil
  }

  public var method: Moya.Method {
    switch self {
      case .adminAttendanceCount:
        return .get

    }
  }

  public var parameters: [String: Any]? {
    switch self {
      case .adminAttendanceCount(let scheduleId):
        return scheduleId.toDictionary(key: "scheduleId")
    }
  }

  public var headers: [String : String]? {
    return APIHeader.baseHeader
  }
}
