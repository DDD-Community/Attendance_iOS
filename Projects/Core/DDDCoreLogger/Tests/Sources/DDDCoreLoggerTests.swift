//
//  DDDCoreLoggerTests.swift
//  DDDCoreLogger
//
//  Created by DDD on 9/1/26.
//

import OSLog
import Testing

@testable import DDDCoreLogger

@Suite("DDDCoreLogger")
struct DDDCoreLoggerTests {
  @Test("카테고리는 OSLog category 문자열 계약을 유지한다")
  func categoriesExposeExpectedRawValues() {
    let rawValues = DDDLogCategory.allCases.map(\.rawValue)

    #expect(rawValues == [
      "app",
      "network",
      "auth",
      "navigation",
      "storage",
      "ui",
      "attendance"
    ])
  }

  @Test("로그 레벨은 심각도 순서대로 정렬된다")
  func logLevelsSortBySeverity() {
    #expect(DDDLogLevel.allCases.sorted() == [
      .debug,
      .info,
      .notice,
      .error,
      .fault
    ])
  }

  @Test("로그 레벨은 OSLogType으로 매핑된다")
  func logLevelsMapToOSLogTypes() {
    #expect(DDDLogLevel.debug.osLogType == .debug)
    #expect(DDDLogLevel.info.osLogType == .info)
    #expect(DDDLogLevel.notice.osLogType == .default)
    #expect(DDDLogLevel.error.osLogType == .error)
    #expect(DDDLogLevel.fault.osLogType == .fault)
  }

  @Test("DEBUG 빌드의 기본 최소 레벨은 debug다")
  func debugBuildMinimumLevelStartsAtDebug() {
    #if DEBUG
    #expect(DDDLogger.defaultMinimumLevel == .debug)
    #else
    #expect(DDDLogger.defaultMinimumLevel == .notice)
    #endif
  }

  @Test("공개 로그 API는 파일 위치 메타데이터와 함께 호출할 수 있다")
  func publicLogAPIsAcceptExplicitCallsiteMetadata() {
    DDDLogger.debug("debug", category: .app, fileID: "Module/File.swift", function: "test()", line: 10)
    DDDLogger.info("info", category: .network, fileID: "Module/File.swift", function: "test()", line: 11)
    DDDLogger.notice("notice", category: .auth, fileID: "Module/File.swift", function: "test()", line: 12)
    DDDLogger.error("error", category: .storage, fileID: "Module/File.swift", function: "test()", line: 13)
    DDDLogger.fault("fault", category: .attendance, fileID: "Module/File.swift", function: "test()", line: 14)

    #expect(Bool(true))
  }
}
