//
//  GoogleOAuthPayload.swift
//  Entity
//
//  Created by Wonji Suh  on 12/29/25.
//

import Foundation

public struct GoogleOAuthPayload {
  public let idToken: String
  public let accessToken: String?
  public let authorizationCode: String?
  public let displayName: String?

  public init(
    idToken: String,
    accessToken: String?,
    authorizationCode: String?,
    displayName: String?
  ) {
    self.idToken = idToken
    self.accessToken = accessToken
    self.authorizationCode = authorizationCode
    self.displayName = displayName
  }
}

// MARK: - Mock Data
public extension GoogleOAuthPayload {
  static func mockData() -> GoogleOAuthPayload {
    return GoogleOAuthPayload(
      idToken: "mock_google_id_token_eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjdkYzIzMDQyYjc5YWI...",
      accessToken: "mock_google_access_token_ya29.a0AfB_byBcDxvKYPzMAeQrK3jJ1uNbFh2mP5sL8wQ9rE6tI3oU7vA2xS1dF4gH...",
      authorizationCode: "mock_google_auth_code_4/0AX4XfWi8GqH2kL5mN7oP9qR3sT1uV2wX3yZ4aB5cD6eF7gH8iJ9kL0mN1oP2qR3sT4uV5wX",
      displayName: "Kim Chulsu"
    )
  }

  static func mockDataWithoutAccessToken() -> GoogleOAuthPayload {
    return GoogleOAuthPayload(
      idToken: "mock_google_id_token_no_access_eyJhbGciOiJSUzI1NiIs...",
      accessToken: nil,
      authorizationCode: "mock_google_auth_code_no_access_xyz123",
      displayName: "Park Minsu"
    )
  }

  static func mockDataWithoutAuthCode() -> GoogleOAuthPayload {
    return GoogleOAuthPayload(
      idToken: "mock_google_id_token_no_auth_eyJhbGciOiJSUzI1NiIs...",
      accessToken: "mock_google_access_token_no_auth_ya29.a0AfB_byBc...",
      authorizationCode: nil,
      displayName: "Choi Jieun"
    )
  }

  static func mockDataWithoutDisplayName() -> GoogleOAuthPayload {
    return GoogleOAuthPayload(
      idToken: "mock_google_id_token_no_name_eyJhbGciOiJSUzI1NiIs...",
      accessToken: "mock_google_access_token_no_name_ya29.a0AfB_byBc...",
      authorizationCode: "mock_google_auth_code_no_name_abc456",
      displayName: nil
    )
  }
}
