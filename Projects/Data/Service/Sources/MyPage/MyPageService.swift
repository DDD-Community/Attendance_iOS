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
    }
  }
  
  public var error: [Int: AsyncMoya.NetworkError]? {
    return nil
  }
  
  public var parameters: [String: Any]? {
    switch self {
    case .fetchAttendances:
      return nil
    }
  }
  
  public var method: Moya.Method {
    switch self {
    case .fetchAttendances:
      return .get
    }
  }
  
  public var headers: [String: String]? {
    return APIHeader.baseHeader
  }
}
