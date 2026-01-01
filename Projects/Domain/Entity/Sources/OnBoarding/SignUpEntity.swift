//
//  UserSession.swift
//  Entity
//
//  Created by Wonji Suh  on 12/31/25.
//

import Foundation

public struct UserSession: Equatable {
  public var name: String
  public var selectPart: SelectParts
  public var userRole: Staff
  public var managing: [StaffManaging]
  public var provider: SocialType
  public var selectTeam: SelectTeams
  public var selectTeamId: Int?
  public var token: String
  public var accessToken: String
  public var generationId : Int
  public var inviteCode: String

  public init(
    name: String = "",
    selectPart: SelectParts = .all,
    userRole: Staff = .member,
    managing: [StaffManaging] = [],
    provider: SocialType = .apple,
    selectTeam: SelectTeams = .unknown,
    selectTeamId: Int? = nil,
    token: String = "",
    generationId: Int = .zero,
    accessToken: String = "",
    inviteCode: String = ""
  ) {
    self.name = name
    self.selectPart = selectPart
    self.userRole = userRole
    self.managing = managing
    self.provider = provider
    self.selectTeam = selectTeam
    self.token = token
    self.generationId = generationId
    self.selectTeamId = selectTeamId
    self.accessToken = accessToken
    self.inviteCode = inviteCode
  }

}


public extension UserSession {
  static let empty = UserSession()
}
