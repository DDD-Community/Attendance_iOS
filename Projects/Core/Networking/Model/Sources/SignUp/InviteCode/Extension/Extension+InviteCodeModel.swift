//
//  Extension+InviteCodeModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/8/25.
//

import Foundation

public extension InviteCodeModel {
  func toSignUpDTOInviteCodeModel() -> InviteDTOModel{
    let data = InviteResponseDTOModel(
      valid: self.data?.valid ?? false,
      inviteCodeID: self.data?.inviteCodeID ?? "",
      inviteType: self.data?.inviteType ?? "",
      oneTimeUse: self.data?.oneTimeUse ?? false,
      errorMessage: self.data?.error ?? ""
    )
    
    return InviteDTOModel(
      code: self.code ?? .zero,
      message: self.message ?? "",
      data: data
    )
  }
}
