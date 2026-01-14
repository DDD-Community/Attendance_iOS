//
//  MyPageAPI.swift
//  API
//
//  Created by 홍은표 on 1/12/26.
//

import Foundation

public enum MyPageAPI: String {
  case fetchAttendances
  case fetchSchedules
  
  public var urlPath: String {
    switch self {
    case .fetchAttendances:
      return "/attendances"
      
    case .fetchSchedules:
      return "/schedules"
    }
  }
}
