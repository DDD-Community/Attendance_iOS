//
//  GoogleOAuthInterface.swift
//  DomainInterface
//
//  Created by Wonji Suh  on 12/29/25.
//

import Foundation
import Entity
import WeaveDI

public protocol GoogleOAuthInterface: Sendable {
  func signIn() async throws -> GoogleOAuthPayload
}

public struct GoogleOAuthRepositoryDependencyKey: DependencyKey {
  public static var liveValue:  GoogleOAuthInterface {
    UnifiedDI.resolve(GoogleOAuthInterface.self) ?? MockGoogleOAuthRepository()
  }
  public static var previewValue:  GoogleOAuthInterface {
    UnifiedDI.resolve(GoogleOAuthInterface.self) ?? MockGoogleOAuthRepository()
  }
  public static var testValue:  GoogleOAuthInterface = MockGoogleOAuthRepository()
}

public extension DependencyValues {
  var googleOAuthRepository:  GoogleOAuthInterface {
    get { self[GoogleOAuthRepositoryDependencyKey.self] }
    set { self[GoogleOAuthRepositoryDependencyKey.self] = newValue }
  }
}

