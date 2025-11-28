//
//  BaseAPI.swift
//  API
//
//  Created by Wonji Suh  on 4/8/25.
//

import Foundation
import AsyncMoya

public enum BaseAPI : String {
  case base
  
  public var apiDescription: String {
    switch self {
    case .base:
      return "https://\(Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String ?? "")"
    }
  }
}




public enum AttendanceDomain {
  case auth
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
      return "accounts/"
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
