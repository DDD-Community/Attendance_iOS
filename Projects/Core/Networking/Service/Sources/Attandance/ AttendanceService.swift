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

public enum AttendanceService{
  case getAttendances(startDate: String)
  case attendanceCount(startDate: String)
  case filterAttendance(startDate: String, team: String)
  case filterScheduleAttendance(userId: Int, scheduleId: String)
  case modifyAttendance(attendanceId: String)

}

extension AttendanceService: BaseTargetType {
  public var domain: AttandanceDomain {
    return .attendances
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
    }
  }
  
  public var error: [Int : NetworkError]? {
    return nil
  }
  
  public var method: Moya.Method {
    switch self {
    case .getAttendances, .attendanceCount, .filterAttendance, .filterScheduleAttendance:
      return .get
      
    case .modifyAttendance:
      return .patch
    }
  }
  
  
  public var parameters: [String : Any]? {
    switch self {
    case .getAttendances(let stratDate):
      let parameters: [String: Any] = [
        "start_date": stratDate,
        "end_date": stratDate
      ]
      return parameters
      
    case .attendanceCount(let startDate):
      let parameters: [String: Any] = [
        "start_date": startDate,
        "end_date": startDate,
      ]
      return parameters
      
    case .filterAttendance(
      let startDate,
      let team):
      let parameters: [String: Any] = [
        "start_date": startDate,
        "end_date": startDate,
        "team": team
      ]
      return parameters
      
    case .filterScheduleAttendance(
      let userId,
      let scheduleId
    ):
      let parameters: [String: Any] = [
        "user_id": userId,
        "start_date": "2025-05-24",
        "end_date": "2025-05-24"
//        "schedule_id": scheduleId,
      ]
      return parameters
      
    case .modifyAttendance( _):
      let parameters: [String: Any] = [
        "status": "present",
        "method": "qr",
        "note": "qr 출석"
      ]
      return parameters
    }
    
  }
  
  public var headers: [String : String]? {
    return APIHeader.baseHeader
  }
}
