//
//  Extension+AttendanceCountModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/14/25.
//

import Foundation

public extension AttendanceCountModel {
  func toAttendanceCountToDTOModel() -> AttendanceCountDTOModel {
    let data = AttendanceCountDTOResponseModel(
      attendanceCount: self.data?.attendanceCount ?? .zero,
      presentCount: self.data?.presentCount ?? .zero,
      lateCount: self.data?.lateCount ?? .zero,
      absentCount: self.data?.absentCount ?? .zero,
      exceptionCount: self.data?.exceptionCount ?? .zero,
      tbdCount: self.data?.tbdCount ?? .zero
    )
    
    return AttendanceCountDTOModel(
      code: self.code ?? .zero,
      message: self.message ?? "",
      data: data
    )
  }
}
