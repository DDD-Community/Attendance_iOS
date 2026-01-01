//
//  Dependencies+OAuth.swift
//  UseCase
//
//  Created by Wonji Suh  on 12/29/25.
//

import Foundation
import Dependencies
import DomainInterface

// MARK: - Apple OAuth Provider Registration

extension AppleOAuthProviderDependency {
  public static var liveValue: AppleOAuthProviderInterface {
    AppleOAuthProvider()
  }
}

// MARK: - Google OAuth Provider Registration

extension GoogleOAuthProviderDependency {
  public static var liveValue: GoogleOAuthProviderInterface {
    GoogleOAuthProvider()
  }
}