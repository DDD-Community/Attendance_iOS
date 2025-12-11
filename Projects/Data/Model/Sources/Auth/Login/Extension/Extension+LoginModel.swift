//
//  Extension+LoginModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/9/25.
//

import Foundation

public extension LoginDTOModel {
  func toDomanl() -> LoginModel {
    
    let data = LoginResponseModel(
      email:  self.data?.email ?? "",
      id: self.data?.id ?? .zero,
      accessToken: self.data?.access ?? "",
      refreshToken: self.data?.refresh ?? "",
    )
    
    return LoginModel(
      code: self.code ?? .zero,
      message: self.message ?? "",
      data: data
    )
  }
}
