//
//  AuthSessionManager.swift
//  Repository
//
//  Created by DDD on 1/2/26.
//

import Foundation
import UIKit
import DomainInterface
import Entity
import WeaveDI
import Alamofire

final class AuthSessionManager {
  static let shared = AuthSessionManager()
  
  @Dependency(\.keychainManager) var keychainManager
  
  // 인터셉터가 직접 크리덴셜을 관리하지 않으므로, SessionManager가 크리덴셜을 소유하고 관리합니다.
  var credential: AccessTokenCredential?
  
  let session: Session
  
  // 🔧 메모리 정리용 타이머
  private var memoryCleanupTimer: Timer?
  
  private init() {
    // AuthInterceptor를 세션의 인터셉터로 직접 사용합니다.
    self.session = Session(interceptor: AuthInterceptor())
    setupInitialCredential()
    setupMemoryOptimization()
    
  }
  
  deinit {
    memoryCleanupTimer?.invalidate()
  }
  
  func updateCredential(with tokens: AuthTokens) {
    let newCredential = AccessTokenCredential.make(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken
    )
    self.credential = newCredential
  }
  
  func clear() {
    self.credential = nil
    // 🚀 메모리 최적화: 명시적 메모리 정리
    forceMemoryCleanup()
  }
  
  /// 🚀 메모리 최적화 설정
  private func setupMemoryOptimization() {
    // 주기적 메모리 정리 (30분마다)
    memoryCleanupTimer = Timer.scheduledTimer(withTimeInterval: 1800, repeats: true) { [weak self] _ in
      self?.performPeriodicCleanup()
    }
    
    // 메모리 경고 시 즉시 정리
    NotificationCenter.default.addObserver(
      forName: UIApplication.didReceiveMemoryWarningNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      self?.forceMemoryCleanup()
    }
  }
  
  /// 주기적 메모리 정리
  private func performPeriodicCleanup() {
    
    // 만료된 credential 정리
    if let credential = credential, credential.isExpired {
      self.credential = nil
    }
  }
  
  /// 강제 메모리 정리
  private func forceMemoryCleanup() {
    
    // 모든 credential 정리 (메모리 압박 상황)
    credential = nil
    
    // URLSession 캐시 정리
    session.session.configuration.urlCache?.removeAllCachedResponses()
  }
}

private extension AuthSessionManager {
  func setupInitialCredential() {
    if let loadedCredential = loadCredentialFromKeychain() {
      self.credential = loadedCredential
    }
  }
  
  func loadCredentialFromKeychain() -> AccessTokenCredential? {
    let accessToken = keychainManager.accessToken()
    let refreshToken = keychainManager.refreshToken()
    
    guard
      let accessToken = accessToken,
      let refreshToken = refreshToken,
      !accessToken.isEmpty,
      !refreshToken.isEmpty
    else {
      return nil
    }
    
    return AccessTokenCredential.make(
      accessToken: accessToken,
      refreshToken: refreshToken
    )
  }
}
