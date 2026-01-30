//
//  EditProfileInput.swift
//  Entity
//
//  Created by Claude on 1/6/26.
//

import Foundation

public struct EditProfileInput {
  public let name: String
  public let generationId: Int
  public let jobRole: SelectParts
  public let teamId: Int?
  public let managerRoles: [StaffManaging]?
  public let inviteCode: String



  public init(
    name: String,
    generationId: Int,
    jobRole: SelectParts,
    teamId: Int?,
    managerRoles: [StaffManaging]?,
    inviteCode: String
  ) {
    self.name = name
    self.generationId = generationId
    self.jobRole = jobRole
    self.teamId = teamId
    self.managerRoles = managerRoles
    self.inviteCode = inviteCode
  }
}

// MARK: - Mock Data
public extension EditProfileInput {
  static func mockData() -> EditProfileInput {
    return EditProfileInput(
      name: "김철수",
      generationId: 1,
      jobRole: .ios,
      teamId: 1,
      managerRoles: [.attendanceCheck],
      inviteCode: "INVITE_CODE_123"
    )
  }

  static func mockManagerInput() -> EditProfileInput {
    return EditProfileInput(
      name: "이영희",
      generationId: 1,
      jobRole: .android,
      teamId: 2,
      managerRoles: [.teamManaging, .scheduleReminder, .photo],
      inviteCode: "MANAGER_INVITE_456"
    )
  }

  static func mockMemberInput() -> EditProfileInput {
    return EditProfileInput(
      name: "박민수",
      generationId: 2,
      jobRole: .frontend,
      teamId: 3,
      managerRoles: nil,
      inviteCode: "MEMBER_INVITE_789"
    )
  }
}
