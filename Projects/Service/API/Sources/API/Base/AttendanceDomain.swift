//
//  AttendanceDomain.swift
//  API
//
//  Created by DDD on 12/29/25.
//

import Foundation

public enum AttendanceDomain {
  case auth
  case onboarding
  case user
  case admin
  case me
  case qr
  case schedule
  case attendance
  case myPage
  case vote
}

public extension AttendanceDomain {
  public var url: String {
    switch self {
    case .auth:
      return "api/auth/"
    case .onboarding:
      return "api/onboarding/"
    case .admin:
      return "api/admin"
    case .me:
      return "api/me"
    case .user:
      return "api/users"
    case .qr:
      return "api/users"
    case .schedule:
      return "api/schedules"
    case .attendance:
      return "api/attendances"
    case .myPage:
      return "api/me"
    case .vote:
      return "api/votes"
    }
  }
}
