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
}

extension ScheduleService: BaseTargetType {
  public var domain: AttandanceDomain {
    return .schedule
  }
  
  public var urlPath: String {
    switch self {
    case .getSchedule:
      return ScheduleAPI.scedules.scheduleDescription
    }
  }
  
  public var error: [Int : NetworkError]? {
    return nil
  }
  
  public var method: Moya.Method {
    switch self {
    case .getSchedule:
      return .get
    }
  }
  
  public var parameters: [String : Any]? {
    switch self {
    case .getSchedule:
      return nil
    }
  }
  
  public var headers: [String : String]? {
    return APIHeader.baseHeader
  }
}
