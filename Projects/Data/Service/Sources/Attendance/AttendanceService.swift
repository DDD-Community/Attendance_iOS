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
  case fetchTeams
}

extension AttendanceService: BaseTargetType {
  public typealias Domain = AttendanceDomain

  public var domain: AttendanceDomain {
    switch self {
      case .adminAttendanceCount, .fetchTeams:
        return .admin
    }
  }

  public var urlPath: String {
    switch self {
    case .adminAttendanceCount(let scheduleId):
      return AttendanceAPI.adminAttendanceCount(scheduleId: scheduleId).description

      case .fetchTeams:
        return AttendanceAPI.fetchTeams.description

    }
  }

  public var error: [Int : AsyncMoya.NetworkError]? {
    return  nil
  }

  public var method: Moya.Method {
    switch self {
      case .adminAttendanceCount, .fetchTeams:
        return .get

    }
  }

  public var parameters: [String: Any]? {
    switch self {
      case .adminAttendanceCount(let scheduleId):
        return scheduleId.toDictionary(key: "scheduleId")

      case .fetchTeams:
        return nil
    }
  }

  public var headers: [String : String]? {
    return APIHeader.baseHeader
  }
}
