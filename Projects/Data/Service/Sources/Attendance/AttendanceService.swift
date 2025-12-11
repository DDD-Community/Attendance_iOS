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
  case getAttendances(startDate: String, endDate: String)
  case attendanceCount(startDate: String)
  case filterAttendance(startDate: String, team: String)
  case filterScheduleAttendance(userId: Int, scheduleId: String, startDate: String)
  case modifyAttendance(attendanceId: String)
  case fetchCount(userID: Int)
}

extension AttendanceService: BaseTargetType {
  public typealias Domain = AttendanceDomain

  public var domain: AttendanceDomain {
    return .attendance
  }

  public var urlPath: String {
    switch self {
    case .getAttendances, .filterScheduleAttendance:
      return AttendanceAPI.getAttandances.attendanceDescription

    case .attendanceCount:
      return AttendanceAPI.attendanceCount.attendanceDescription

    case .filterAttendance:
      return AttendanceAPI.getAttandances.attendanceDescription

    case .modifyAttendance(let attendanceId):
      return AttendanceAPI.editAttendance(attendanceId: attendanceId).attendanceDescription

    case .fetchCount:
      return AttendanceAPI.fetchCount.attendanceDescription
    }
  }

  public var error: [Int : AsyncMoya.NetworkError]? {
    return  nil
  }

  public var method: Moya.Method {
    switch self {
    case .getAttendances, .attendanceCount, .filterAttendance, .filterScheduleAttendance:
      return .get

    case .modifyAttendance:
      return .patch

    case .fetchCount:
      return .get
    }
  }

  public var parameters: [String: Any]? {
    switch self {
    case .getAttendances(let stratDate, let endDate):
      let parameters: [String: Any] = [
        "start_date": stratDate,
        "end_date": endDate
      ]
      return parameters

    case .attendanceCount(let startDate):
      let parameters: [String: Any] = [
        "start_date": startDate,
        "end_date": startDate,
      ]
      return parameters

    case .filterAttendance(let startDate, let team):
      let parameters: [String: Any] = [
        "start_date": startDate,
        "end_date": startDate,
        "team": team
      ]
      return parameters

    case .filterScheduleAttendance(
      let userId,
      let scheduleId,
      let startDate
    ):
      let parameters: [String: Any] = [
        "user_id": userId,
        "start_date": startDate,
        "end_date": startDate,
        "schedule_id": scheduleId,
      ]
      return parameters

    case .modifyAttendance( _):
      let parameters: [String: Any] = [
        "status": "auto",
        "method": "qr",
        "note": "qr 출석"
      ]
      return parameters

    case .fetchCount(let userID):
      return ["user_id": userID]
    }
  }

  public var headers: [String : String]? {
    return APIHeader.baseHeader
  }
}
