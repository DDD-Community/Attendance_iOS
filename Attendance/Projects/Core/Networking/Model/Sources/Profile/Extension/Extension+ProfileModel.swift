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
      role: self.data?.role ?? "",
      team: SelectPart(rawValue: self.data?.team ?? "") ?? .all,
      isStaff: self.data?.isStaff ?? false
    )
    
    return ProfileDTOModel(
      code: self.code ?? .zero,
      message: self.message ?? "",
      data: data
    )
  }
}
