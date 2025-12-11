//
//  Extension+InviteCodeModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/8/25.
//

import Foundation

public extension InviteCodeDTOModel {
  func toDomain() -> InviteCodeModel{
    let data = InviteCodeResponseModel(
      valid: self.data?.valid ?? false,
      inviteCodeID: self.data?.inviteCodeID ?? "",
      inviteType: self.data?.inviteType ?? "",
      oneTimeUse: self.data?.oneTimeUse ?? false,
      errorMessage: self.data?.error ?? ""
    )
    
    return InviteCodeModel(
      code: self.code ?? .zero,
      message: self.message ?? "",
      data: data
    )
  }
}
