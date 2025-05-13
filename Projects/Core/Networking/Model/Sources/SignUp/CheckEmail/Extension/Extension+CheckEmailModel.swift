//
//  Extension+CheckEmailModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/9/25.
//

import Foundation

public extension CheckEmailModel {
  func toCheckEmailDTOModel() -> CheckEmailDTO {
    let data = CheckEmailResponseDTO(emailUsed: self.data?.emailUsed ?? false)
    
    return CheckEmailDTO(
      code: self.code ?? .zero,
      message: self.message ?? "",
      data: data
    )
  }
}
