//
//  DDDAuthorization.swift
//  DDDNetworkInterface
//
//  Copyright © 2026 DDD. All rights reserved.
//

import Foundation

/// 요청의 인증 정책. 토큰 부착 여부는 요청 시점에 credential 유무로 판단한다.
public enum DDDAuthorization: Sendable, Equatable {
  /// 로그인 상태면 토큰 부착 + refresh/재시도, 아니면 토큰 없이 전송 (기본값)
  case automatic
  /// 인증 파이프라인 완전 우회 — 로그인 상태여도 토큰을 붙이지 않고, 401 에도 refresh 하지 않는다
  /// (로그인 / 회원가입 / refresh 자신 등)
  case none
}
