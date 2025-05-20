//
//  Extension+LoginModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/9/25.
//

import Foundation

public extension LoginModel {
  func toLoginDTOModel() -> LoginDTOModel {
    
    let data = LoginResponseDTOModel(
      id: self.data?.id ?? .zero,
      email:  self.data?.email ?? "",
      accessToken: self.data?.access ?? "",
      refreshToken: self.data?.refresh ?? "",
    )
    
    return LoginDTOModel(
      code: self.code ?? .zero,
      message: self.message ?? "",
      data: data
    )
  }
}
