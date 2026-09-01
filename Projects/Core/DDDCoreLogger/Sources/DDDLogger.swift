//
//  DDDLogger.swift
//  DDDCoreLogger
//
//  Copyright © 2026 DDD. All rights reserved.
//

import Foundation
import OSLog

/// os.Logger 기반 전역 로거 (정적 네임스페이스).
/// 값은 항상 `.private` 로 기록 — 릴리즈 통합로그/sysdiagnose 에 평문 유출을 막는다.
/// (개발 중 디버거가 붙은 상태에서는 값이 그대로 보인다)
public enum DDDLogger {
  private static let subsystem: String = Bundle.main.bundleIdentifier ?? "com.ddd.dddattendance"
  /// 이 레벨 미만은 출력 스킵. 릴리즈에선 notice 이상만.
  private static let minimumLevel: DDDLogLevel = DDDLogger.defaultMinimumLevel

  public static func debug(
    _ message: String,
    category: DDDLogCategory,
    fileID: String = #fileID,
    function: String = #function,
    line: Int = #line
  ) {
    emit(.debug, category, message, fileID, function, line)
  }

  public static func info(
    _ message: String,
    category: DDDLogCategory,
    fileID: String = #fileID,
    function: String = #function,
    line: Int = #line
  ) {
    emit(.info, category, message, fileID, function, line)
  }

  public static func notice(
    _ message: String,
    category: DDDLogCategory,
    fileID: String = #fileID,
    function: String = #function,
    line: Int = #line
  ) {
    emit(.notice, category, message, fileID, function, line)
  }

  public static func error(
    _ message: String,
    category: DDDLogCategory,
    fileID: String = #fileID,
    function: String = #function,
    line: Int = #line
  ) {
    emit(.error, category, message, fileID, function, line)
  }

  public static func fault(
    _ message: String,
    category: DDDLogCategory,
    fileID: String = #fileID,
    function: String = #function,
    line: Int = #line
  ) {
    emit(.fault, category, message, fileID, function, line)
  }

  /// 코어 — minimumLevel 통과 시에만 출력. 호출 위치(fileID/function/line)를 머리줄에 붙인다.
  private static func emit(
    _ level: DDDLogLevel,
    _ category: DDDLogCategory,
    _ message: String,
    _ fileID: String,
    _ function: String,
    _ line: Int
  ) {
    guard level >= minimumLevel else { return }

    let logger = Logger(subsystem: subsystem, category: category.rawValue)
    // #fileID 는 "모듈/파일.swift" — 파일명만 떼서 짧게 (절대경로 노출 X).
    let file = fileID.split(separator: "/").last.map(String.init) ?? fileID
    // 메타(이모지/카테고리/위치)는 public 으로 항상 보이게, message 값만 private 로 가린다.
    logger.log(level: level.osLogType, """
    \(level.emoji, privacy: .public) [\(category.rawValue, privacy: .public)] \(message, privacy: .private)
    ↳ \(file, privacy: .public):\(line, privacy: .public) \(function, privacy: .public)
    """)
  }

  /// DEBUG 는 debug 부터, 릴리즈는 notice 부터.
  static var defaultMinimumLevel: DDDLogLevel {
    #if DEBUG
    .debug
    #else
    .notice
    #endif
  }
}
