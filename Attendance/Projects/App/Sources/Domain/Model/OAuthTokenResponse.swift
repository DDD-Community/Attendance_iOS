//
//  OAuthTokenResponse.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/6/24.
//

import Foundation

import FirebaseAuth

struct OAuthTokenResponse: Hashable {
  var accessToken: String
  var refreshToken: String
  var provider: DDDOAuthProvider
  var credential: AuthCredential?
}
