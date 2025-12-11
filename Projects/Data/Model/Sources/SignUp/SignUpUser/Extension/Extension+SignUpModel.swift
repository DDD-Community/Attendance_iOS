//
//  Extension+SignUpModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/7/25.
//

import Foundation

public extension SignUpDTOModel {
  func toDomain() -> SignUpModel {
    
    let user = SignUPUser(
      username: self.user?.username ?? "",
      email: self.user?.email ?? "",
    )
    
    let data = SignUpResponseModel(
      accessToken: self.access ?? "",
      refreshToken: self.refresh ?? "",
      user: user
    )
    
    return SignUpModel(
      code: .zero,
      message: "",
      data: data
    )

  }
}
