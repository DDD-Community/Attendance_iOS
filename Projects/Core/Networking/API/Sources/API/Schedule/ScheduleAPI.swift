//
//  ScheduleAPI.swift
//  API
//
//  Created by Wonji Suh  on 5/9/25.
//

import Foundation

public enum ScheduleAPI: String , CaseIterable {
  case scedules
  
  public var scheduleDescription: String {
    switch self {
    case .scedules:
      return ""
    }
  }
}
