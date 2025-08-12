//
//  OAuthResponse.swift
//  Model
//
//  Created by Wonji Suh  on 10/30/24.
//

import Foundation

import FirebaseAuth

public struct OAuthResponseModel : Equatable {
  public let accessToken: String
  public let refreshToken: String
  public let credential: AuthCredential?
  public let email: String
  public let uid: String

  public init(
    accessToken: String,
    refreshToken: String,
    credential: AuthCredential? = nil,
    email: String,
    uid: String
  ) {
    self.accessToken = accessToken
    self.refreshToken = refreshToken
    self.credential = credential
    self.email = email
    self.uid = uid
  }
}
