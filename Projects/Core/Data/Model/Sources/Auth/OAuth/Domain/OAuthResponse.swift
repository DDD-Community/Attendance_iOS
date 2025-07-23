//
//  OAuthResponse.swift
//  Model
//
//  Created by Wonji Suh  on 10/30/24.
//

import Foundation

import FirebaseAuth

public struct OAuthResponseModel : Equatable {
  public var accessToken: String
  public var refreshToken: String
  public var credential: AuthCredential?
  public var email: String
  public var uid: String

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
