//
//  DDDLogLevel.swift
//  DDDCoreLogger
//
//  Copyright © 2026 DDD. All rights reserved.
//

import Foundation
import OSLog

enum DDDLogLevel: Int, Comparable, CaseIterable {
  /// 개발 중 상세 추적용. 릴리즈엔 남지 않음(휘발).
  case debug
  /// 참고 정보. 릴리즈 디스크엔 저장되지 않음(메모리만).
  case info
  /// 기본 레벨. 릴리즈에서도 persist (눈여겨볼 일반 이벤트).
  case notice
  /// 에러 — 예상치 못한 실패. 릴리즈 persist.
  case error
  /// 심각한 결함 — 앱 동작을 위협하는 치명적 상황. 릴리즈 persist.
  case fault

  static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.rawValue < rhs.rawValue
  }

  var osLogType: OSLogType {
    switch self {
    case .debug: .debug
    case .info: .info
    case .notice: .default
    case .error: .error
    case .fault: .fault
    }
  }

  var emoji: String {
    switch self {
    case .debug: "⚪️"
    case .info: "🔵"
    case .notice: "🟢"
    case .error: "🟡"
    case .fault: "🔴"
    }
  }
}
