//
//  AuthToken.swift
//  Entity
//
//  Created by Wonji Suh  on 12/29/25.
//

import Foundation

public struct AuthTokens: Equatable, Hashable {
  public let accessToken: String
  public let refreshToken: String
  public let oauthRefreshToken: String?

  public init(
    accessToken: String,
    refreshToken: String,
    oauthRefreshToken: String? = nil
  ) {
    self.accessToken = accessToken
    self.refreshToken = refreshToken
    self.oauthRefreshToken = oauthRefreshToken
  }
}

// MARK: - Mock Data
public extension AuthTokens {
  static func mockData() -> AuthTokens {
    return AuthTokens(
      accessToken: "mock_access_token_eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      refreshToken: "mock_refresh_token_def456_abc123_ghi789",
      oauthRefreshToken: "mock_oauth_refresh_token_xyz987_uvw654_rst321"
    )
  }

  static func mockGoogleTokens() -> AuthTokens {
    return AuthTokens(
      accessToken: "mock_google_access_token_gcp_eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
      refreshToken: "mock_google_refresh_token_1//0GeTt4uFrpoCgYIARAAGA...",
      oauthRefreshToken: "mock_google_oauth_refresh_ya29.a0AfB_byBc..."
    )
  }

  static func mockAppleTokens() -> AuthTokens {
    return AuthTokens(
      accessToken: "mock_apple_access_token_aps_eyJraWQiOiJBNkdVVUtyTDNhIn0...",
      refreshToken: "mock_apple_refresh_token_cf5d8bc1fb5e4e9c8a7b3d2e1f0a9b8c7d6e5f4a3b2c1d0e9f8a7b6c5d4e3f2a1b0c9d8e7f6a5b4c3d2e1f0",
      oauthRefreshToken: nil
    )
  }

  static func mockExpiredTokens() -> AuthTokens {
    return AuthTokens(
      accessToken: "expired_access_token_xxx",
      refreshToken: "expired_refresh_token_yyy",
      oauthRefreshToken: "expired_oauth_refresh_token_zzz"
    )
  }
}
