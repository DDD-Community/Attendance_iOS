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
  case getUserProfile
  case getAdminProfile
  case editProfile(body:EditProfileRequestDTO)
}


extension ProfileService: BaseTargetType {
  public typealias Domain = AttendanceDomain

  public var domain: AttendanceDomain {
    switch self {
      case .getUserProfile:
        return .me

      case .getAdminProfile:
        return .admin

      case .editProfile:
        return .user
    }
  }
  
  public var urlPath: String {
    switch self {
      case .getUserProfile:
      return ProfileAPI.getUser.profileDescription

      case .getAdminProfile:
        return ProfileAPI.getAdmin.profileDescription

      case .editProfile:
        return ProfileAPI.editUser.profileDescription
    }
  }
  
  public var error: [Int : AsyncMoya.NetworkError]? {
    return  nil
  }

  public var method: Moya.Method {
    switch self {
      case .getUserProfile, .getAdminProfile:
      return .get

      case .editProfile:
        return .put
    }
  }
  

  public var parameters: [String : Any]? {
    switch self {
      case .getUserProfile, .getAdminProfile:
      return nil

      case .editProfile(let body):
        return body.toDictionary
    }
  }
   
  public var headers: [String : String]? {
    return APIHeader.baseHeader
  }
  
}
