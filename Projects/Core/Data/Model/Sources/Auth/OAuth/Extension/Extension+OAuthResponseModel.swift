//
//  Extension+OAuthResponseModel.swift
//  Model
//
//  Created by Wonji Suh  on 11/4/24.
//

import Foundation

import FirebaseAuth

public extension OAuthResponseDTOModel {
  func toDomain() -> OAuthResponseModel {
    return OAuthResponseModel(
      accessToken: self.accessToken,
      refreshToken: self.refreshToken,
      credential: self.credential,
      email: self.email,
      uid: self.uid
    )
  }
}
