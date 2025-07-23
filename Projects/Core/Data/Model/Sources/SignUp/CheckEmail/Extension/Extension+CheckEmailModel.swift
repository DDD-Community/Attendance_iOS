//
//  Extension+CheckEmailModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/9/25.
//

import Foundation

public extension CheckEmailDTOModel {
  func toDomain() -> CheckEmailModel {
    let data = CheckEmailResponseModel(emailUsed: self.data?.emailUsed ?? false)

    return CheckEmailModel(
      code: self.code ?? .zero,
      message: self.message ?? "",
      data: data
    )
  }
}
