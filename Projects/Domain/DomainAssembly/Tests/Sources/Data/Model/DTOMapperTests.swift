//
//  DTOMapperTests.swift
//  ModelTests
//
//  Created by DDD on 2026-09-02
//  Copyright © 2026 DDD , Ltd. All rights reserved.
//

import Foundation
import Testing

@testable import AppUpdateDomain
@testable import AttendanceDomain
@testable import AuthDomain
@testable import MyPageDomain
@testable import OnBoardingDomain
@testable import ProfileDomain
@testable import QRCodeDomain
@testable import ScheduleDomain
@testable import VoteDomain

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

  @Test("온보딩 팀 응답은 WEB 3팀과 NATIVE 팀을 SelectTeamEntity로 변환한다")
  func onboardingTeamsResponseMapsToDomain() throws {
    let json = """
    [
      { "teamId": 13, "name": "WEB 1팀", "serviceName": null },
      { "teamId": 14, "name": "WEB 2팀", "serviceName": null },
      { "teamId": 15, "name": "WEB 3팀", "serviceName": null },
      { "teamId": 18, "name": "NATIVE 1팀", "serviceName": null },
      { "teamId": 19, "name": "NATIVE 2팀", "serviceName": null }
    ]
    """

    let dto = try JSONDecoder().decode(SelectTeamsDTO.self, from: Data(json.utf8))
    let entities = dto.toDomain()

    #expect(entities.map(\.teamId) == [13, 14, 15, 18, 19])
    #expect(entities.map(\.teams) == [.web1, .web2, .web3, .native1, .native2])
    #expect(entities.orderedSelectTeams() == [.web1, .web2, .web3, .native1, .native2])
  }
}
