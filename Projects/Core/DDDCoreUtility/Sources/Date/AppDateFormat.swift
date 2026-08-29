//
//  AppDateFormat.swift
//  DDDCoreUtility
//
//  Copyright © 2026 DDD. All rights reserved.
//

import Foundation

public enum AppDateFormat: String, CaseIterable, Sendable {
  case dateTime = "yyyy-MM-dd HH:mm:ss"
  case yearMonthDay = "yyyy-MM-dd"
  case fullKoreanDate = "yyyy년 MM월 dd일"
  case yearMonthDayDotted = "yyyy.MM.dd"
}

private enum AppDateFormatter {
  private static let locale = Locale(identifier: "en_US_POSIX")
  private static let timeZone = TimeZone(identifier: "Asia/Seoul") ?? .gmt
  private static let calendar = Calendar(identifier: .gregorian)

  /// 서버 날짜 문자열 파싱 전용
  static let parser: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = locale
    formatter.timeZone = timeZone
    formatter.calendar = calendar
    formatter.dateFormat = AppDateFormat.dateTime.rawValue
    return formatter
  }()

  /// 화면 출력 전용
  private static let formatters: [AppDateFormat: DateFormatter] = Dictionary(
    uniqueKeysWithValues: AppDateFormat.allCases.map { format in
      let formatter = DateFormatter()
      formatter.locale = locale
      formatter.timeZone = timeZone
      formatter.calendar = calendar
      formatter.dateFormat = format.rawValue

      return (format, formatter)
    }
  )

  static subscript(format: AppDateFormat) -> DateFormatter {
    formatters[format]!
  }
}

public extension String {
  var date: Date? {
    AppDateFormatter.parser.date(from: self)
  }

  func date(as format: AppDateFormat) -> Date? {
    AppDateFormatter[format].date(from: self)
  }
}

public extension Date {
  func formatted(_ format: AppDateFormat) -> String {
    AppDateFormatter[format].string(from: self)
  }
}
