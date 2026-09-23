//
//  DDDCredentialTests.swift
//  DDDNetwork
//
//  토큰 사전 갱신 판정을 검증한다. 401 을 받기 전에 미리 갱신하는 근거가 되는 값이다.
//  Copyright © 2026 DDD. All rights reserved.
//

import Foundation
import Testing

import DDDNetworkInterface

@Suite("DDDCredential — 갱신 필요 판정")
struct DDDCredentialTests {
  private func credential(expiresIn seconds: TimeInterval?, leeway: TimeInterval = 300) -> DDDCredential {
    DDDCredential(
      accessToken: "access",
      refreshToken: "refresh",
      expiresAt: seconds.map { Date().addingTimeInterval($0) },
      refreshLeeway: leeway
    )
  }

  @Test("만료 시각이 없으면 갱신하지 않는다 — 401 을 받고 나서야 갱신한다")
  func noExpiryMeansNoRefresh() {
    #expect(credential(expiresIn: nil).requiresRefresh == false)
  }

  @Test("여유 시간보다 많이 남았으면 갱신하지 않는다")
  func farFromExpiryDoesNotRefresh() {
    #expect(credential(expiresIn: 600, leeway: 300).requiresRefresh == false)
  }

  @Test("여유 시간 안으로 들어오면 만료 전이라도 갱신한다")
  func withinLeewayRefreshes() {
    #expect(credential(expiresIn: 120, leeway: 300).requiresRefresh == true)
  }

  @Test("이미 만료됐으면 갱신한다")
  func expiredRefreshes() {
    #expect(credential(expiresIn: -60).requiresRefresh == true)
  }

  @Test("여유 시간이 0이면 만료 시각까지는 갱신하지 않는다")
  func zeroLeewayWaitsUntilExpiry() {
    #expect(credential(expiresIn: 10, leeway: 0).requiresRefresh == false)
  }
}
