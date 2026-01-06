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
  case editProfile(body:EditProfileRequestDTO)
}


extension ProfileService: BaseTargetType {
  public typealias Domain = AttendanceDomain

  public var domain: AttendanceDomain {
    switch self {
      case .getProfile, .editProfile:
        return .user
    }
  }
  
  public var urlPath: String {
    switch self {
    case .getProfile:
      return ProfileAPI.getUser.profileDescription

      case .editProfile:
        return ProfileAPI.editUser.profileDescription
    }
  }
  
  public var error: [Int : AsyncMoya.NetworkError]? {
    return  nil
  }

  public var method: Moya.Method {
    switch self {
    case .getProfile:
      return .get

      case .editProfile:
        return .put
    }
  }
  

  public var parameters: [String : Any]? {
    switch self {
    case .getProfile:
      return nil

      case .editProfile(let body):
        return body.toDictionary
    }
  }
   
  public var headers: [String : String]? {
    return APIHeader.baseHeader
  }
  
}
