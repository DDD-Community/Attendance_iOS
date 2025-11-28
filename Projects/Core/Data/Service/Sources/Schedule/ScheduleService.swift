//
//  ScheduleService.swift
//  Service
//
//  Created by Wonji Suh  on 5/9/25.
//

import Foundation

import Foundations
import API

import AsyncMoya

public enum ScheduleService {
  case getSchedule
  case filterSchedule(stratDate: String)
}

extension ScheduleService: BaseTargetType {
  public typealias Domain = AttendanceDomain

  public var domain: AttendanceDomain {
    return .schedule
  }
  
  public var urlPath: String {
    switch self {
    case .getSchedule, .filterSchedule:
      return ScheduleAPI.scedules.scheduleDescription
    }
  }
  
  public var error: [Int : AsyncMoya.NetworkError]? {
    return  nil
  }

  public var method: Moya.Method {
    switch self {
    case .getSchedule, .filterSchedule:
      return .get
    }
  }
  
  public var parameters: [String : Any]? {
    switch self {
    case .getSchedule:
      return nil
      
    case .filterSchedule(let stratDate):
      let parameters: [String: Any] = [
        "start_date": stratDate,
        "end_date": stratDate
      ]
      return parameters
      
    }
  }
  
  public var headers: [String : String]? {
    return APIHeader.baseHeader
  }
}
