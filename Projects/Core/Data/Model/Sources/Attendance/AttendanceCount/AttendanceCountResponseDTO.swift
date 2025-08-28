//
//  AttendanceCountResponseDTO.swift
//  Model
//
//  Created by eunpyo on 5/18/25.
//

import Foundation

public struct AttendanceCountResponseDTO: Decodable {
  let attendanceCount: Int
  let presentCount: Int
  let lateCount: Int
  let absentCount: Int
  let exceptionCount: Int
  let tbdCount: Int

  enum CodingKeys: String, CodingKey {
    case attendanceCount = "attendance_count"
    case presentCount = "present_count"
    case lateCount = "late_count"
    case absentCount = "absent_count"
    case exceptionCount = "exception_count"
    case tbdCount = "tbd_count"
  }
}
