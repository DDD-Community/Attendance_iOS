//
//  CredentialUpdating.swift
//  DDDNetworkInterface
//
//  Copyright © 2026 DDD. All rights reserved.
//

import Foundation

/// 인증 세션의 credential 을 외부에서 교체하는 핸들.
/// 인터셉터는 생성 시점의 credential 을 캐시하므로, 로그인 / 로그아웃 시점에
/// 이 핸들로 세션에 반영해야 이후 요청에 새 토큰이 실린다. (nil = credential 제거)
public protocol CredentialUpdating: Sendable {
  func update(_ credential: DDDCredential?)
}
