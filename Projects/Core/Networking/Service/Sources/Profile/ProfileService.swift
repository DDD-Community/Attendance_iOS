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
  case editProfile(
    username: String,
    inviteCodeId: String,
    role: String,
    crew: String,
    responsibility: String
  )
  case getProfile
}


extension ProfileService: BaseTargetType {
  public var domain: AttandanceDomain {
    return .profile
  }
  
  public var urlPath: String {
    switch self {
    case .editProfile:
      return ProfileAPI.editProfile.profileDescription
      
    case .getProfile:
      return ProfileAPI.getProfile.profileDescription
    }
  }
  
  public var error: [Int : Foundations.NetworkError]? {
    return nil
  }
  
  public var method: Moya.Method {
    switch self {
    case .editProfile:
      return .patch
      
    case .getProfile:
      return .get
    }
  }
  

  public var parameters: [String : Any]? {
    switch self {
    case .editProfile(
      let username,
      let inviteCodeId,
      let role,
      let crew,
      let  responsibility):
      let parameters: [String: Any] = [
        "name":  username,
        "invite_code_id": inviteCodeId,
        "role":  role,
        "team":  crew,
        "cohort": "12",
        "crew": crew,
        "responsibility":responsibility
      ]
      return parameters
          
    case .getProfile:
      return nil
    }
  }
   
  public var headers: [String : String]? {
    return APIHeader.baseHeader
  }
  
}
