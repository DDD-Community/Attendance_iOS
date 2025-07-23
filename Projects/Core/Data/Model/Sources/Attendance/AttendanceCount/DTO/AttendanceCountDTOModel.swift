//
//  AttendanceCountDTOModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/14/25.
//

import Foundation

public typealias AttendanceCountDTOModel = BaseResponseDTO<AttendanceCountDTOResponseModel>

// MARK: - DataClass
public struct AttendanceCountDTOResponseModel: Decodable, Equatable {
  public let attendanceCount, presentCount, lateCount, absentCount: Int
  public let exceptionCount, tbdCount: Int
  
  public init(
    attendanceCount: Int,
    presentCount: Int,
    lateCount: Int,
    absentCount: Int,
    exceptionCount: Int,
    tbdCount: Int
  ) {
    self.attendanceCount = attendanceCount
    self.presentCount = presentCount
    self.lateCount = lateCount
    self.absentCount = absentCount
    self.exceptionCount = exceptionCount
    self.tbdCount = tbdCount
  }
}
