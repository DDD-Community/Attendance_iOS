//
//  AuthService.swift
//  DDDAuthInterface
//
//  Created by DDD on 9/1/26.
//

import Foundation

/// 앱의 인증 상태를 저장소와 네트워크 세션에 동시에 반영하는 단일 진입점.
/// Repository는 Keychain이나 `CredentialUpdating`을 직접 다루지 않고 이 계약만 사용한다.
public protocol AuthService: Sendable {
  /// 저장소에 유효한 access/refresh token 쌍이 있는지 확인한다.
  var isLoggedIn: Bool { get async }
  /// 저장된 refresh token을 반환한다.
  var refreshToken: String? { get async }

  /// 로그인 성공 토큰을 영속화하고 이후 인증 요청에 즉시 반영한다.
  func signIn(accessToken: String, refreshToken: String) async
  /// 영속 토큰과 현재 네트워크 세션 credential을 함께 제거한다.
  func signOut() async
}

public extension Notification.Name {
  /// refresh token이 서버에서 거부되어 재로그인이 필요할 때 발행된다.
  static let dddAuthSessionDidExpire = Notification.Name("dddauth.session.didExpire")
}
