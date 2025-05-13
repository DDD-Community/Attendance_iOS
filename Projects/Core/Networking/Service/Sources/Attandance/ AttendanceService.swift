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
  case getAttendances
  case attendanceCount(startDate: String)

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
    }
  }
  
  public var error: [Int : NetworkError]? {
    return nil
  }
  
  public var method: Moya.Method {
    switch self {
    case .getAttendances, .attendanceCount:
      return .get
    }
  }
  
  
  public var parameters: [String : Any]? {
    switch self {
    case .getAttendances:
      return nil
      
    case .attendanceCount(let startDate):
      let parameters: [String: Any] = [
        "start_date": startDate,
        "end_date": startDate
      ]
      return parameters
      
    }
  }
  
  public var headers: [String : String]? {
    return APIHeader.baseHeader
  }
}
