//
//  Extension+RefreshTokenModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/9/25.
//

import Foundation

public extension RefreshTokenModel {
  func toRefreshDTOModel() -> RefreshTokenDTOModel {
    let user = UserDTO(username: self.data?.user?.username ?? "", email: self.data?.user?.email ?? "")
    
    let data = RefreshTokenDTPResponseModel(
      refreshToken: self.data?.refreshToken ?? "",
      accessToken: self.data?.accessToken ?? "",
      user: user,
    )
    
    return RefreshTokenDTOModel(
      code: self.code ?? .zero,
      message: self.message ?? "",
      data: data
    )
  }
}
