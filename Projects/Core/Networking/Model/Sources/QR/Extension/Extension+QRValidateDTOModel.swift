//
//  Extension+QRValidateDTOModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/20/25.
//

import Foundation

public extension QRValidateDTOModel {
  func toDomain() -> QRValidateModel {
    let data = QRValidateResponseModel(
      valid: self.data?.valid ?? false,
      userID: self.data?.userID ?? .zero,
      username: self.data?.username ?? ""
    )
    
    return QRValidateModel(
      code: self.code ?? .zero,
      message: self.message ?? "",
      data: data
    )
  }
}
