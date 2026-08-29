//
//  SignUpUserDTO+.swift
//  Model
//
//  Created by DDD on 1/1/26.
//

import Foundation

import Entity

public extension SignUpUserDTO {
  func toDomain() -> SignUpUser {
    return SignUpUser(
      name: self.name,
      email: self.email ?? "",
      generation: self.generation,
      team: {
        guard let team = self.team else { return nil }
        return SelectTeams.from(name: team)
      }(),
      managing: self.managerRoles?.compactMap { StaffManaging.from(apiKey: $0) },
      selectPart: SelectParts.from(apiKey: self.jobRole) ?? .all
    )
  }
}
