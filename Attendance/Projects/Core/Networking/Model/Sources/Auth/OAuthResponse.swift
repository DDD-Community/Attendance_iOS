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
  
  public init(accessToken: String, refreshToken: String, credential: AuthCredential? = nil) {
    self.accessToken = accessToken
    self.refreshToken = refreshToken
    self.credential = credential
  }
}
