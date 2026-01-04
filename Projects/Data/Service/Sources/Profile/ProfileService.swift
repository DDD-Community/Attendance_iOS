//
//  ProfileService.swift
//  Service
//
//  Created by Wonji Suh  on 5/8/25.
//

import Foundation

import API
import Foundations

import AsyncMoya

public enum ProfileService{
  case getProfile
}


extension ProfileService: BaseTargetType {
  public typealias Domain = AttendanceDomain

  public var domain: AttendanceDomain {
    switch self {
      case .getProfile:
        return .user
    }
  }
  
  public var urlPath: String {
    switch self {
    case .getProfile:
      return ProfileAPI.getUser.profileDescription
    }
  }
  
  public var error: [Int : AsyncMoya.NetworkError]? {
    return  nil
  }

  public var method: Moya.Method {
    switch self {
    case .getProfile:
      return .get
    }
  }
  

  public var parameters: [String : Any]? {
    switch self {
    case .getProfile:
      return nil
    }
  }
   
  public var headers: [String : String]? {
    return APIHeader.baseHeader
  }
  
}
