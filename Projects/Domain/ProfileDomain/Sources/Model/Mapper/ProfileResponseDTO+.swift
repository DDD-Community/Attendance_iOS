//
//  ProfileResponseDTO+.swift
//  ProfileDomain
//
//  Created by DDD on 5/14/25.
//

import Foundation

public extension ProfileResponseDTO {
  func toDomain() -> ProfileResponseModel {
    return .init(
      id: id ?? "",
      userID: userID ?? 0,
      name: name,
      inviteCodeID: inviteCodeID ?? "",
      role: .init(rawValue: role ?? "") ?? .all,
      team: .init(rawValue: team ?? "") ?? .notTeam,
      crew: .init(rawValue: team ?? "") ?? .notTeam,
      responsibility: .init(rawValue: responsibility ?? "") ?? .notManaging,
      cohort: cohort ?? "",
      cohortID: cohortID ?? "",
      isStaff: isStaff ?? false
    )
  }
}
