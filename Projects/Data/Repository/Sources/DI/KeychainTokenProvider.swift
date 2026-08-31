//
//  KeychainTokenProvider.swift
//  Repository
//
//  Foundations 의 TokenProviding 구현. 키체인에서 액세스 토큰을 읽고 쓴다.
//  KeychainManaging 은 DomainInterface 의 의존성 키로 주입받는다.
//

import Dependencies
import DomainInterface
import Foundations

struct KeychainTokenProvider: TokenProviding {
  @Dependency(\.keychainManager) private var keychainManager

  func accessToken() -> String? {
    keychainManager.accessToken()
  }

  func saveAccessToken(_ token: String) {
    keychainManager.saveAccessToken(token)
  }
}
