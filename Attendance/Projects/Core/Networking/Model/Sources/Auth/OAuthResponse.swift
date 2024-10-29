//
//  OAuthResponse.swift
//  Model
//
//  Created by Wonji Suh  on 10/30/24.
//

import Foundation


public struct OAuthResponseModel : Equatable {
  public var accessToken: String
  public var refreshToken: String
  
  public init(accessToken: String, refreshToken: String) {
    self.accessToken = accessToken
    self.refreshToken = refreshToken
  }
}
