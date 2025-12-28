//
//  String+.swift
//  Utill
//
//  Created by Wonji Suh  on 11/4/24.
//

import Foundation

public extension String {
  static func makeQrCodeValue(
    userID: String,
    eventID: String,
    startTime: Date,
    endTime: Date
  ) -> String {
    let startTimeString = startTime.formattedString()
    let setEndTime = endTime.addingTimeInterval(1800)
    let endTimeString = setEndTime.formattedString()
    return "\(userID)+\(eventID)+\(startTimeString)+\(endTimeString)"
  }
  
  static func stringToDate(_ dateString: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "ko_KR")
    dateFormatter.dateFormat = "yyyy년 MM월 dd일"
    return dateFormatter.date(from: dateString)
  }
  
  static func stringToTimeAndDate(_ dateString: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "ko_KR")
    dateFormatter.dateFormat = "yyyy년 MM월 dd일 a hh시 mm분"
    return dateFormatter.date(from: dateString)
  }
  
  static func stringToTimeFirebaseDate(_ dateString: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "ko_KR")
    dateFormatter.dateFormat = "yyyy년 MM월 dd일 a hh시 mm분 ss초 'UTC'Z"
    return dateFormatter.date(from: dateString)
  }
  
  static func extractMonth(from isoDate: String) -> String {
    let components = isoDate.split(separator: "T").first?.split(separator: "-")
    return components?.count == 3 ? String(components![1]) : ""
  }
  
  static func extractDay(from isoDate: String) -> String {
    let components = isoDate.split(separator: "T").first?.split(separator: "-")
    return components?.count == 3 ? String(components![2]) : ""
  }
  
  static func extractMonthString(from isoDate: String) -> String {
      let comps = isoDate.split(separator: "T").first?.split(separator: "-")
      if let month = comps?[1] {
        return "\(Int(month) ?? 0)월"
      }
      return ""
    }

  static func monthOnlyString(from input: String) -> String? {
    // "10:000" -> "10:00.000" 보정
    let fixed = input.replacingOccurrences(
      of: #"T(\d{2}):(\d{2})(\d{3})([+\-]\d{2}:\d{2})$"#,
      with: #"T$1:$2.$3$4"#,
      options: .regularExpression
    )

    let iso = ISO8601DateFormatter()
    iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

    let date: Date?
    if let d = iso.date(from: fixed) {
      date = d
    } else {
      iso.formatOptions = [.withInternetDateTime]
      date = iso.date(from: fixed)
    }
    guard let date else { return nil }

    let out = DateFormatter()
    out.locale = Locale(identifier: "ko_KR")
    out.timeZone = TimeZone(identifier: "Asia/Seoul")
    out.dateFormat = "MM월"   // ✅ 08월
    return out.string(from: date)
  }

  static func dayOnlyString(from input: String) -> String? {
    // "10:000" -> "10:00.000" 보정
    let fixed = input.replacingOccurrences(
      of: #"T(\d{2}):(\d{2})(\d{3})([+\-]\d{2}:\d{2})$"#,
      with: #"T$1:$2.$3$4"#,
      options: .regularExpression
    )

    let iso = ISO8601DateFormatter()
    iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

    let date: Date?
    if let d = iso.date(from: fixed) {
      date = d
    } else {
      iso.formatOptions = [.withInternetDateTime]
      date = iso.date(from: fixed)
    }
    guard let date else { return nil }

    let out = DateFormatter()
    out.locale = Locale(identifier: "ko_KR")
    out.timeZone = TimeZone(identifier: "Asia/Seoul")
    out.dateFormat = "d일"   // ✅ 16일
    return out.string(from: date)
  }

  static func splitBySlash(_ input: String) -> (left: String, right: String) {
    let components = input.components(separatedBy: " / ")
    let left = components.first ?? ""
    let right = components.count > 1 ? components[1] : ""
    return (left, right)
  }
}
