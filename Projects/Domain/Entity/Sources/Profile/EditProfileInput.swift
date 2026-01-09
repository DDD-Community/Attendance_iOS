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
