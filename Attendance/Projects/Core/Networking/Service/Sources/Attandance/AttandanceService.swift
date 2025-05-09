//
//  AttandanceService.swift
//  Service
//
//  Created by Wonji Suh  on 5/10/25.
//

import Foundation

import API
import Foundations

import AsyncMoya

public enum AttandanceService{
  case getAttandances
}

extension AttandanceService: BaseTargetType {
  public var domain: AttandanceDomain {
    return .attendances
  }
  
  public var urlPath: String {
    switch self {
    case .getAttandances:
      return AttandanceAPI.getAttandances.attandanceDescription
    }
  }
  
  public var error: [Int : NetworkError]? {
    return nil
  }
  
  public var method: Moya.Method {
    switch self {
    case .getAttandances:
      return .get
    }
  }
  
  
  public var parameters: [String : Any]? {
    switch self {
    case .getAttandances:
      return nil
    }
  }
  
  public var headers: [String : String]? {
    return APIHeader.baseHeader
  }
}
