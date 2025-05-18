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

}

extension AttendanceService: BaseTargetType {
  public var domain: AttandanceDomain {
    return .attendances
  }
  
  public var urlPath: String {
    switch self {
    case .getAttendances:
      return AttendanceAPI.getAttandances.attendanceDescription
      
    case .attendanceCount:
      return AttendanceAPI.attendanceCount.attendanceDescription
      
    case .filterAttendance:
      return AttendanceAPI.getAttandances.attendanceDescription
    }
  }
  
  public var error: [Int : NetworkError]? {
    return nil
  }
  
  public var method: Moya.Method {
    switch self {
    case .getAttendances, .attendanceCount, .filterAttendance:
      return .get
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
    }
  }
  
  public var headers: [String : String]? {
    return APIHeader.baseHeader
  }
}
