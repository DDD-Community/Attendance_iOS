//
//  Extension+LoginModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/9/25.
//

import Foundation

public extension LoginModel {
  func toLoginDTOModel() -> LoginDTOModel {
    let userDTO = UserDTO(username: self.user?.username ?? "", email: self.user?.email ?? "")
    
    let data = LoginResponseDTOModel(
      accessToken: self.access ?? "",
      refreshToken: self.refresh ?? "",
      user: userDTO,
      accessExpiration: self.accessExpiration ?? "",
      refreshExpiration: self.refreshExpiration ?? ""
    )
    
    return LoginDTOModel(
      code: .zero,
      message: "",
      data: data
    )
  }
}
