//
//  OAuthResponse.swift
//  Model
//
//  Created by Wonji Suh  on 10/30/24.
//

import Foundation

import FirebaseAuth

public struct OAuthResponseModel : Equatable {
   var accessToken: String
   var refreshToken: String
   var credential: AuthCredential?
   var email: String
  var uid: String
  
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
