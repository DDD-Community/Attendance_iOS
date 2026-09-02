//
//  ModelMappingTests.swift
//  ModelTests
//
//  Created by DDD on 9/2/26.
//

import Entity
import Foundation
import Testing

@testable import Model

struct ModelMappingTests {
  @Test("출석 요약 DTO는 집계 값을 손실 없이 도메인으로 변환한다")
  func attendanceSummaryMapsAllCounts() {
    let dto = AttendanceSummaryResponseDTO(
      totalAttended: 7,
      totalLate: 2,
      totalAbsent: 1
    )

    let domain = dto.toDomain()

    #expect(domain.totalAttended == 7)
    #expect(domain.totalLate == 2)
    #expect(domain.totalAbsent == 1)
  }

  @Test("로그인 DTO는 누락된 토큰을 빈 문자열로 보정한다")
  func loginResponseDefaultsMissingTokens() throws {
    let json = """
    {
      "message": "ok",
      "isNewUser": false,
      "oauthProvider": "google",
      "role": "MEMBER"
    }
    """.data(using: .utf8)!
    let dto = try JSONDecoder().decode(LoginResponseDTO.self, from: json)

    let domain = dto.toDomain()

    #expect(domain.provider == .google)
    #expect(domain.token.accessToken.isEmpty)
    #expect(domain.token.refreshToken.isEmpty)
  }
}
