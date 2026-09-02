//
//  DTOMapperTests.swift
//  ModelTests
//
//  Created by DDD on 2026-09-02
//  Copyright © 2026 DDD , Ltd. All rights reserved.
//

import Entity
import Testing

@testable import Model

@Suite("Model DTO Mapper")
struct DTOMapperTests {
  @Test("LoginResponseDTO는 토큰과 역할을 LoginEntity로 변환한다")
  func loginResponseMapsToDomain() {
    let dto = LoginResponseDTO(
      userId: 1,
      name: "김철수",
      email: "ios@ddd.kr",
      oauthProvider: "GOOGLE",
      message: "ok",
      isNewUser: false,
      accessToken: "access",
      refreshToken: "refresh",
      oauthRefreshToken: "oauth",
      role: "MEMBER"
    )

    let entity = dto.toDomain()

    #expect(entity.name == "김철수")
    #expect(entity.provider == .google)
    #expect(entity.token.accessToken == "access")
    #expect(entity.token.refreshToken == "refresh")
    #expect(entity.token.oauthRefreshToken == "oauth")
    #expect(entity.role == .member)
  }

  @Test("VerifyCodeDTO는 generationId와 staff type을 VerifyCodeEntity로 변환한다")
  func verifyCodeMapsToDomain() {
    let dto = VerifyCodeDTO(
      generationID: 13,
      generationName: "13기",
      type: "MANAGER",
      description: "운영진 코드"
    )

    let entity = dto.toDomain()

    #expect(entity.generationID == 13)
    #expect(entity.type == .manager)
  }
}
