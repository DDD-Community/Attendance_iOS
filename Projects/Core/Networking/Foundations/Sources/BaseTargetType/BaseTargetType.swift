//
//  BaseTargetType.swift
//  Foundations
//
//  Created by Wonji Suh  on 5/7/25.
//


import Foundation
import Moya
import API

public enum AttandanceDomain {
  case auth
  case invite
  case profile
  case qr
  case schedule
  case attendances
  
}

extension AttandanceDomain {
  var url: String {
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
    case .attendances:
      return "api/v1/attendances/"
    }
  }
}


public protocol BaseTargetType: TargetType {
  var domain: AttandanceDomain { get }
  var urlPath: String { get }
  var error: [Int: NetworkError]? { get }
  var parameters: [String: Any]? { get }
}

public extension BaseTargetType {
   var baseURL: URL {
    return URL(string: BaseAPI.base.apiDescription)!
  }
  
  var path: String {
    return domain.url + urlPath
  }
  
  var headers: [String: String]? {
    return APIHeader.notAccessTokenHeader
  }
  
  var task: Moya.Task {
    if let parameters = parameters {
      if method == .get {
        return .requestParameters(
          parameters: parameters,
          encoding: URLEncoding.queryString
        )
      } else {
        return .requestParameters(
          parameters: parameters,
          encoding: JSONEncoding.default
        )
      }
    }
    return .requestPlain
  }
  
}
