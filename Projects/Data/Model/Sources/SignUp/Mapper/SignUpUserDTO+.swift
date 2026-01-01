//
//  SignUpUserDTO+.swift
//  Model
//
//  Created by Wonji Suh  on 1/1/26.
//

import Foundation

import Entity

public extension SignUpUserDTO {
  func toDomain() -> SignUpUser {
    return SignUpUser(
      name: self.name,
      email: self.email,
      generation: self.generation,
      team: SelectTeams.from(name: self.team),
      managing: self.managerRoles.compactMap { StaffManaging.from(apiKey: $0) },
      selectPart: SelectParts.from(apiKey: self.jobRole) ?? .all
    )
  }
}
