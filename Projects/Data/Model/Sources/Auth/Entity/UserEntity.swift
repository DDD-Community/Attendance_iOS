//
//  UserEntity.swift
//  Model
//
//  Created by Wonji Suh  on 5/7/25.
//

import Foundation
import Entity

public enum UserRole: String {
  case member    = "member"
  case moderator = "moderator"
}


public struct UserEntity: Equatable{
  
  public static let shared = UserEntity()
  
  public var userEmail: String
  public var userName: String
  public var signUpName: String
  public var userUid: String
  public var accessToken: String
  public var refreshToken: String
  public var inviteCodeId: String?
  public var userRole: UserRole?
  public var managing: Managing?
  public var role: SelectPart?
  public var memberTeam: SelectTeam?

  // 프로필에서 가져온 역할 정보 (Staff enum)
  public var staffRole: Staff?
  
  
  public init(
    userEmail: String = "",
    userName: String = "",
    signUpName: String = "",
    userUid: String = "",
    accessToken: String = "",
    refreshToken: String = "",
    inviteCodeId: String? = nil,
    userRole: UserRole = .moderator,
    managing: Managing? = nil,
    role: SelectPart? = nil,
    memberTeam: SelectTeam? = nil,
    staffRole: Staff? = nil
  ) {
    self.userEmail = userEmail
    self.userUid = userUid
    self.signUpName = signUpName
    self.accessToken = accessToken
    self.refreshToken = refreshToken
    self.inviteCodeId = inviteCodeId
    self.userName = userName
    self.userRole = userRole
    self.role = role
    self.managing = managing
    self.memberTeam = memberTeam
    self.staffRole = staffRole
  }
  
}
