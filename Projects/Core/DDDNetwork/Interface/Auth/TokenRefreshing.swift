//
//  TokenRefreshing.swift
//  DDDNetworkInterface
//
//  Copyright © 2026 DDD. All rights reserved.
//

import Foundation

/// 토큰 refresh 추상. refresh API 호출은 앱(Repository)이 구현한다.
/// 401 또는 만료 임박 시 Alamofire `Authenticator` 가 이 메서드로 새 토큰을 받는다.
public protocol TokenRefreshing: Sendable {
  func refresh(_ current: DDDCredential) async throws(DDDNetworkError) -> DDDCredential
}
