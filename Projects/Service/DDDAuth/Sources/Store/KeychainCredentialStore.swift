//
//  KeychainCredentialStore.swift
//  DDDAuth
//
//  Created by DDD on 9/1/26.
//

import DDDNetworkInterface
import DDDStorageInterface

/// 범용 `SecureStorage`를 DDDNetwork의 credential 저장 계약으로 변환한다.
final class KeychainCredentialStore: CredentialStore {
  /// access token과 refresh token을 보관하는 보안 저장소다.
  private let storage: any SecureStorage

  /// 범용 보안 저장소를 credential 저장소로 감싼다.
  init(storage: any SecureStorage) {
    self.storage = storage
  }

  /// 저장된 토큰 쌍이 모두 유효할 때만 credential을 복원한다.
  func load() -> DDDCredential? {
    guard let accessToken = try? storage.load(.accessToken),
          !accessToken.isEmpty,
          let refreshToken = try? storage.load(.refreshToken),
          !refreshToken.isEmpty
    else {
      return nil
    }
    return DDDCredential(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: JWTDecoder.decodeExpiration(accessToken)
    )
  }

  /// access token과 refresh token을 각각의 보안 키로 저장한다.
  func save(_ credential: DDDCredential) {
    try? storage.save(credential.accessToken, for: .accessToken)
    try? storage.save(credential.refreshToken, for: .refreshToken)
  }

  /// 인증 종료 시 보안 저장소의 모든 인증 값을 제거한다.
  func clear() {
    try? storage.removeAll()
  }
}
