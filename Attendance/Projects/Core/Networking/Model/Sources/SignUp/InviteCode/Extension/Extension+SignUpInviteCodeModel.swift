//
//  Extension+SignUpInviteCodeModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/8/25.
//

import Foundation

public extension SignUpInviteCodeModel {
  func toSignUpDTOInviteCodeModel() -> SignUPInviteDTOModel{
    let data = SignUPInviteResponseDTOModel(
      valid: self.data?.valid ?? false,
      inviteCodeID: self.data?.inviteCodeID ?? "",
      inviteType: self.data?.inviteType ?? "",
      oneTimeUse: self.data?.oneTimeUse ?? false,
      errorMessage: self.data?.error ?? ""
    )
    
    return SignUPInviteDTOModel(
      code: self.code ?? .zero,
      message: self.message ?? "",
      data: data
    )
  }
}
