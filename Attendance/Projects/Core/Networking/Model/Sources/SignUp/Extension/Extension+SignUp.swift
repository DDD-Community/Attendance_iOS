//
//  Extension+SignUp.swift
//  Model
//
//  Created by Wonji Suh  on 11/3/24.
//

import Foundation

public extension InviteModel {
  func toModel() -> InviteDTOModel {
    return InviteDTOModel(
      code: self.code ?? "",
      expireData: self.expiredDate ?? Date(),
      isAdmin: self.isAdmin ?? false
    )
  }
  
}
