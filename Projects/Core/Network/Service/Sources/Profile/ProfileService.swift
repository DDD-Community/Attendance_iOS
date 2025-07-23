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
  case editProfileManger(
    username: String,
    inviteCodeId: String,
    role: String,
    team: String,
    responsibility: String
  )
  case editProfileMangerNoTeam(
      username: String,
      inviteCodeId: String,
      role: String,
      responsibility: String
  )
  case editProfileMember(
    username: String,
    inviteCodeId: String,
    role: String,
    team: String
  )
  case getProfile
}


extension ProfileService: BaseTargetType {
  public var domain: AttendanceDomain {
    return .profile
  }
  
  public var urlPath: String {
    switch self {
    case .editProfileManger, .editProfileMangerNoTeam, .editProfileMember:
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
    case .editProfileManger, .editProfileMangerNoTeam , .editProfileMember:
      return .patch
      
    case .getProfile:
      return .get
    }
  }
  

  public var parameters: [String : Any]? {
    switch self {
    case .editProfileManger(
      let username,
      let inviteCodeId,
      let role,
      let team,
      let responsibility):
      let parameters: [String: Any] = [
        "name":  username,
        "invite_code_id": inviteCodeId,
        "role":  role,
        "team":  team,
        "cohort": "12",
        "responsibility":responsibility
      ]
      return parameters
      
    case .editProfileMangerNoTeam(
      let username,
      let inviteCodeId,
      let role,
      let responsibility):
      let parameters: [String: Any] = [
      "name" :  username,
      "invite_code_id": inviteCodeId,
      "role":  role,
      "cohort": "12",
      "responsibility":responsibility
    ]
    return parameters
      
    case .editProfileMember(
      let username,
      let inviteCodeId,
      let role,
      let team):
      let parameters: [String: Any] = [
        "name":  username,
        "invite_code_id": inviteCodeId,
        "role":  role,
        "team":  team,
        "cohort": "12",
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
