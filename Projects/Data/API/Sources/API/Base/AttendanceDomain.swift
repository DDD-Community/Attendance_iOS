//
//  AttendanceDomain.swift
//  API
//
//  Created by Wonji Suh  on 12/29/25.
//

import Foundation

import AsyncMoya

public enum AttendanceDomain {
  case auth
  case onboarding
  case user
  case invite
  case profile
  case qr
  case schedule
  case attendance
}

extension AttendanceDomain: DomainType {
  public var baseURLString: String {
    return BaseAPI.base.apiDescription
  }

  public var url: String {
    switch self {
      case .auth:
        return "api/auth/"
      case .onboarding:
        return "api/onboarding/"
      case .user:
        return "api/users"
      case .invite:
        return "api/v1/invites/"
      case .profile:
        return "api/v1/profiles/"
      case .qr:
        return "api/v1/qrcodes/"
      case .schedule:
        return "api/v1/schedules/"
      case .attendance:
        return "api/v1/attendances/"
    }
  }
}
