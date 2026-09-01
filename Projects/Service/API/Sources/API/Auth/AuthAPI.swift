//
//  AuthAPI.swift
//  API
//
//  Created by DDD on 5/9/25.
//

import Foundation

public enum AuthAPI: String, CaseIterable {
  case login
  case refresh
  case withDraw
  case logout

  public var path: String {
    switch self {
    case .login:
      return AttendanceDomain.auth.url + "login"
    case .refresh:
      return AttendanceDomain.auth.url + "refresh"
    case .withDraw:
      return AttendanceDomain.user.url + "/me"
    case .logout:
      return AttendanceDomain.auth.url + "logout"
    }
  }
}
