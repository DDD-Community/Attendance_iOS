//
//  Extension+OAuthResponseModel.swift
//  Model
//
//  Created by Wonji Suh  on 11/4/24.
//

import Foundation
import FirebaseAuth

public extension OAuthResponseModel {
  func toDTOModel() -> OAuthResponseDTOModel {
    return OAuthResponseDTOModel(
      accessToken: self.accessToken,
      refreshToken: self.refreshToken,
      credential: self.credential,
      email: self.email,
      uid: self.uid
    )
  }
}
