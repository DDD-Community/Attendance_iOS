//
//  AttandanceAPI.swift
//  API
//
//  Created by Wonji Suh  on 5/10/25.
//

import Foundation

public enum AttendanceAPI: String, CaseIterable {
  case getAttandances
  case attendanceCount
   
  public var attendanceDescription: String {
    switch self {
    case .getAttandances:
      return ""
      
    case .attendanceCount:
      return "count/"
    }
  }
}
