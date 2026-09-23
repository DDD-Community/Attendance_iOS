//
//  CredentialStore.swift
//  DDDNetworkInterface
//
//  Copyright © 2026 DDD. All rights reserved.
//

import Foundation

/// 토큰 저장소 추상. 앱이 구현(키체인 등)해 주입한다.
/// 클라이언트는 이걸 통해 토큰을 읽고, refresh 된 토큰을 다시 저장한다.
public protocol CredentialStore: Sendable {
  /// 저장된 토큰 (없으면 nil)
  func load() -> DDDCredential?
  /// 토큰 저장 (refresh 후 영속화)
  func save(_ credential: DDDCredential)
  /// 토큰 삭제 (로그아웃 등)
  func clear()
}
