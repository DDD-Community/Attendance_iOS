//
//  ProfileDTO+.swift
//  Model
//
//  Created by Wonji Suh  on 1/4/26.
//

import Foundation
import Entity

public extension ProfileDTO {
  func toDomain() -> ProfileEntity {
    return ProfileEntity(
      name: self.name,
      generation: self.generation,
      team: SelectTeams(rawValue: self.team ?? ""),
      jobRole: SelectParts(rawValue: self.team ?? "") ?? .all,
      manger: self.managerRoles.compactMap { StaffManaging.from(apiKey: $0) },
    )
  }
}
