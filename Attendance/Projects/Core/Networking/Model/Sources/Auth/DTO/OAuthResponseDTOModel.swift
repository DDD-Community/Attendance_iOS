//
//  OAuthResponseDTOModel.swift
//  Model
//
//  Created by Wonji Suh  on 11/4/24.
//
import Foundation

import FirebaseAuth

public struct OAuthResponseDTOModel : Equatable {
  public var accessToken: String
  public var refreshToken: String
  public var credential: AuthCredential?
  public var email: String
  
  public init(
    accessToken: String,
    refreshToken: String,
    credential: AuthCredential? = nil,
    email: String
  ) {
    self.accessToken = accessToken
    self.refreshToken = refreshToken
    self.credential = credential
    self.email = email
  }
}
