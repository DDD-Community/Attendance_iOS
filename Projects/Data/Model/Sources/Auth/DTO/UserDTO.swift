//
//  UserDTO.swift
//  Model
//
//  Created by Wonji Suh  on 5/7/25.
//

import Foundation

import Entity

public struct UserDTO: Equatable {
  public static let shared = UserDTO()

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
  public var staffRole: Staff?

  public init(
    userEmail: String = "",
    userName: String = "",
    signUpName: String = "",
    userUid: String = "",
    accessToken: String = "",
    refreshToken: String = "",
    inviteCodeId: String? = nil,
    userRole: UserRole? = .moderator,
    managing: Managing? = nil,
    role: SelectPart? = nil,
    memberTeam: SelectTeam? = nil,
    staffRole: Staff? = nil
  ) {
    self.userEmail = userEmail
    self.userName = userName
    self.signUpName = signUpName
    self.userUid = userUid
    self.accessToken = accessToken
    self.refreshToken = refreshToken
    self.inviteCodeId = inviteCodeId
    self.userRole = userRole
    self.managing = managing
    self.role = role
    self.memberTeam = memberTeam
    self.staffRole = staffRole
  }
}
