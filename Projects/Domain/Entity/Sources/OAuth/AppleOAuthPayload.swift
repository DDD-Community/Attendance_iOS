//
//  AppleOAuthPayload.swift
//  Entity
//
//  Created by Wonji Suh  on 12/29/25.
//

import Foundation

public struct AppleOAuthPayload {
  public let idToken: String
  public let authorizationCode: String?
  public let displayName: String?
  public let nonce: String

  public init(
    idToken: String,
    authorizationCode: String?,
    displayName: String?,
    nonce: String,
  ) {
    self.idToken = idToken
    self.authorizationCode = authorizationCode
    self.displayName = displayName
    self.nonce = nonce
  }
}

// MARK: - Mock Data
public extension AppleOAuthPayload {
  static func mockData() -> AppleOAuthPayload {
    return AppleOAuthPayload(
      idToken: "mock_apple_id_token_eyJraWQiOiJBNkdVVUtyTDNhIn0.eyJpc3MiOiJodHRwczovL2FwcGxlaWQuYXBwbGUuY29tIiwiYXVkIjoiY29tLmRkZC5hdHRlbmRhbmNlIiwiZXhwIjoxNjc...",
      authorizationCode: "mock_apple_auth_code_c5d8bc1fb5e4e9c8a7b3d2e1f0a9b8c7d6e5f4a3b2c1d0e9f8a7b6c5d4e3f2a1b0c9d8e7f6a5b4c3d2e1f0",
      displayName: "Kim Chulsu",
      nonce: "mock_apple_nonce_abc123_def456_ghi789_jkl012_mno345"
    )
  }

  static func mockDataWithoutName() -> AppleOAuthPayload {
    return AppleOAuthPayload(
      idToken: "mock_apple_id_token_no_name_eyJraWQiOiJBNkdVVUtyTDNhIn0...",
      authorizationCode: "mock_apple_auth_code_no_name_xyz789",
      displayName: nil,
      nonce: "mock_apple_nonce_no_name_pqr456"
    )
  }

  static func mockDataWithoutAuthCode() -> AppleOAuthPayload {
    return AppleOAuthPayload(
      idToken: "mock_apple_id_token_no_auth_eyJraWQiOiJBNkdVVUtyTDNhIn0...",
      authorizationCode: nil,
      displayName: "Lee Younghee",
      nonce: "mock_apple_nonce_no_auth_stu901"
    )
  }
}
