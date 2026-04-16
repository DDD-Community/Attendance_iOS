//
//  MyPageService.swift
//  Service
//
//  Created by 홍은표 on 1/12/26.
//

import Foundation

import API
import Foundations
import AsyncMoya

public enum MyPageService: Sendable {
  case fetchAttendances
  case fetchSchedules
}

extension MyPageService: BaseTargetType {
  public typealias Domain = AttendanceDomain

  public var domain: AttendanceDomain {
    return .myPage
  }
  
  public var urlPath: String {
    switch self {
    case .fetchAttendances:
      return MyPageAPI.fetchAttendances.urlPath
    case .fetchSchedules:
      return MyPageAPI.fetchSchedules.urlPath
    }
  }
  
  public var error: [Int: AsyncMoya.NetworkError]? {
    return nil
  }
  
  public var parameters: [String: Any]? {
    switch self {
    case .fetchAttendances:
      return nil
    case .fetchSchedules:
      return nil
    }
  }
  
  public var method: Moya.Method {
    switch self {
    case .fetchAttendances, .fetchSchedules:
      return .get
    }
  }
  
  public var headers: [String: String]? {
    return APIHeader.baseHeader
  }
}
