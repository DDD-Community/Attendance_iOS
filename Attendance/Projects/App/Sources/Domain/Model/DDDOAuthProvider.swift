//
//  OAuthProvider.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/6/24.
//

import Foundation

enum DDDOAuthProvider {
  case apple
  case google
  
  var service: OAuthServiceProtocol {
    switch self {
    case .apple: return OAuthAppleService()
    case .google: return OAuthGoogleService()
    }
  }
}
