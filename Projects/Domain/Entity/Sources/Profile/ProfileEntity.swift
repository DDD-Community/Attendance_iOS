//
//  ProfileEntity.swift
//  Entity
//
//  Created by Wonji Suh  on 1/4/26.
//

import Foundation

public struct ProfileEntity: Equatable {
  public let name: String
  public let generation: String
  public let team: SelectTeams?
  public let jobRole: SelectParts
  public let manger: [StaffManaging]?

  public init(
    name: String,
    generation: String,
    team: SelectTeams?,
    jobRole: SelectParts,
    manger: [StaffManaging]?
  ) {
    self.name = name
    self.generation = generation
    self.team = team
    self.jobRole = jobRole
    self.manger = manger
  }
}
