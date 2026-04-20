//
//  KeychainTokenProvider.swift
//  DDDAttendance
//
//  Created by Wonji Suh  on 1/2/26.
//

import Foundation
// 필요 모듈만 사용
import DomainInterface
import Foundations

struct KeychainTokenProvider: TokenProviding {
  private let keychainManager: KeychainManaging

  init(keychainManager: KeychainManaging) {
    self.keychainManager = keychainManager
  }

  func accessToken() -> String? {
    keychainManager.accessToken()
  }

  func saveAccessToken(_ token: String) {
    keychainManager.saveAccessToken(token)
  }
}
