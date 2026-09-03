//
//  ProfileEntity.swift
//  Entity
//
//  Created by DDD on 1/4/26.
//

import Foundation

public struct ProfileEntity: Equatable {
  public let userID: Int
  public let name: String
  public let generation: String
  public let team: SelectTeams?
  public let jobRole: SelectParts
  public let role: Staff
  public let manger: [StaffManaging]?

  public init(
    userID: Int,
    name: String,
    generation: String,
    team: SelectTeams?,
    jobRole: SelectParts,
    role: Staff,
    manger: [StaffManaging]?
  ) {
    self.userID = userID
    self.name = name
    self.generation = generation
    self.team = team
    self.jobRole = jobRole
    self.role = role
    self.manger = manger
  }
}