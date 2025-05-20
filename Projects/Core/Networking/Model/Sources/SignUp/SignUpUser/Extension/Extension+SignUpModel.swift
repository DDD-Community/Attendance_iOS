//
//  Extension+SignUpModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/7/25.
//

import Foundation

public extension SignUpModel {
  func toSIgnUpDTOModel() -> SignUpDTOModel {
    
    let user = UserDTO(
      username: self.user?.username ?? "",
      email: self.user?.email ?? "",
    )
    
    let data = SignUpResponseDTOModel(
      accessToken: self.access ?? "",
      refreshToken: self.refresh ?? "",
      user: user
    )
    
    return SignUpDTOModel(data: data)
    
  }
}
