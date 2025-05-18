//
//  ProfileResponseDTO+.swift
//  Model
//
//  Created by eunpyo on 5/14/25.
//

import Foundation

public extension ProfileResponseDTO {
  func toDomain() -> ProfileResponseModel {
    return .init(
      id: id ?? "",
      userID: userID ?? 0,
      name: name,
      inviteCodeID: inviteCodeID ?? "",
      role: role ?? "",
      team: team ?? "",
      cohort: cohort ?? "",
      isStaff: isStaff ?? false,
      createdAt: createdAt ?? "",
      updatedAt: updatedAt ?? ""
    )
  }
}
