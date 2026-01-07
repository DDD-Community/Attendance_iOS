//
//  SignUpUserRequestDTO.swift
//  Service
//
//  Created by Wonji Suh  on 1/1/26.
//

public struct SignUpUserRequestDTO: Encodable {
  public let profile: BaseUserProfileDTO
  public let authentication: AuthenticationDTO

  public init(
    profile: BaseUserProfileDTO,
    authentication: AuthenticationDTO
  ) {
    self.profile = profile
    self.authentication = authentication
  }

  // 기존 방식과의 호환성을 위한 편의 이니셜라이저
  public init(
    name: String,
    generationId: Int,
    jobRole: String,
    teamId: Int?,
    managerRoles: [String]?,
    provider: String,
    token: String,
    oauthRefreshToken: String? = nil,
    invitationCode: String
  ) {
    self.profile = BaseUserProfileDTO(
      name: name,
      generationId: generationId,
      jobRole: jobRole,
      teamId: teamId,
      managerRoles: managerRoles,
      invitationCode: invitationCode
    )
    self.authentication = AuthenticationDTO(
      provider: provider,
      token: token,
      oauthRefreshToken: oauthRefreshToken
    )
  }

  // Flat 구조로 인코딩하기 위한 커스텀 인코딩
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: DynamicCodingKeys.self)

    // 기본 프로필 정보
    try container.encode(profile.name, forKey: DynamicCodingKeys(stringValue: "name")!)
    try container.encode(profile.generationId, forKey: DynamicCodingKeys(stringValue: "generationId")!)
    try container.encode(profile.jobRole, forKey: DynamicCodingKeys(stringValue: "jobRole")!)
    try container.encode(profile.teamId, forKey: DynamicCodingKeys(stringValue: "teamId")!)
    try container.encode(profile.managerRoles, forKey: DynamicCodingKeys(stringValue: "managerRoles")!)
    try container.encode(authentication.provider, forKey: DynamicCodingKeys(stringValue: "provider")!)
    try container.encode(profile.invitationCode, forKey: DynamicCodingKeys(stringValue: "invitationCode")!)

    // provider에 따라 다른 토큰 키 사용
    try container.encode(authentication.token, forKey: DynamicCodingKeys(stringValue: "token")!)

    if authentication.provider.lowercased() == "apple", let refreshToken = authentication.oauthRefreshToken {
      // Apple의 경우 oauthRefreshToken도 추가로 인코딩
      try container.encode(refreshToken, forKey: DynamicCodingKeys(stringValue: "oauthRefreshToken")!)
    }
  }

  // 동적 CodingKey를 위한 헬퍼 구조체
  private struct DynamicCodingKeys: CodingKey {
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
      self.stringValue = stringValue
    }

    init?(intValue: Int) {
      self.intValue = intValue
      self.stringValue = String(intValue)
    }
  }
}
