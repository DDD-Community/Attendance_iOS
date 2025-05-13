//
//  AttendanceCountModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/14/25.
//

import Foundation

public typealias AttendanceCountModel = BaseResponse<AttendanceCountResponseModel>

// MARK: - DataClass
public struct AttendanceCountResponseModel: Decodable {
  let attendanceCount, presentCount, lateCount, absentCount: Int?
  let exceptionCount, tbdCount: Int?
  
  enum CodingKeys: String, CodingKey {
    case attendanceCount = "attendance_count"
    case presentCount = "present_count"
    case lateCount = "late_count"
    case absentCount = "absent_count"
    case exceptionCount = "exception_count"
    case tbdCount = "tbd_count"
  }
}

