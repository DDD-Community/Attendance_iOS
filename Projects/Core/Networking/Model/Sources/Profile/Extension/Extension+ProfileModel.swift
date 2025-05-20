//
//  Extension+ProfileModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/9/25.
//

import Foundation

public extension ProfileModel {
  func toProfileDTOModel() -> ProfileDTOModel {
    let data = ProfileResponseDTO(
      id: self.data?.id ?? "",
      name: self.data?.name ?? "",
      inviteCodeID: self.data?.inviteCodeID ?? "",
      role: SelectPart(rawValue: self.data?.role ?? "") ?? .all,
      team: SelectTeam(rawValue: self.data?.team ?? "") ?? .notTeam,
      isStaff: self.data?.isStaff ?? false,
      generation: self.data?.cohort ?? "",
      crew: SelectTeam(rawValue: self.data?.crew ?? "") ?? .notTeam,
      responsibility: Managing(rawValue: self.data?.responsibility ?? "") ?? .notManaging
    )
    
    return ProfileDTOModel(
      code: self.code ?? .zero,
      message: self.message ?? "",
      data: data
    )
  }
}
