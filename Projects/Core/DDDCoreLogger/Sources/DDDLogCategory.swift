//
//  DDDLogCategory.swift
//  DDDCoreLogger
//
//  Copyright © 2026 DDD. All rights reserved.
//

import Foundation

/// 로그 카테고리. os.Logger 의 category 로 쓰인다.
public enum DDDLogCategory: String, Sendable, CaseIterable {
  /// 앱 전반 / 생명주기 (실행, 초기화, 어디에도 안 맞는 일반 로그)
  case app
  /// 네트워크 통신 (요청/응답/에러)
  case network
  /// 인증 (로그인, 토큰 갱신/만료)
  case auth
  /// 화면 전환 / 라우팅
  case navigation
  /// 로컬 저장소 (키체인, UserDefaults, 캐시 등)
  case storage
  /// UI / 사용자 인터랙션
  case ui
  /// 출석 도메인 (체크인, 스케줄, 출결 상태)
  case attendance
}
