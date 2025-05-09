//
//  Extension+CheckEmailModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/9/25.
//

import Foundation

public extension CheckEmailModel {
  func toCheckEmailDTOModel() -> CheckEmailDTO {
    let data = CheckEmailResponseDTO(emailUsed: self.emailUsed ?? false)
    
    return CheckEmailDTO(
      code: 0,
      message: "",
      data: data
    )
  }
}
