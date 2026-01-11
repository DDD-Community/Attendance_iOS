//
//  AttendanceDTOModel+.swift
//  Model
//
//  Created by Wonji Suh  on 1/11/26.
//

import Entity

public extension AttendanceDTOResponse {
  func toDomain() -> Attendance {
    return Attendance(
      id: self.attendanceID,
      userID: self.userID,
      userName: self.userName,
      userInfo: self.userInfo,
      status: AttendanceStatus.from(apiKey: self.attendanceStatus) ?? .absent
    )
  }
}



public extension Array where Element == AttendanceDTOResponse {
  func toDomain() -> [Attendance] {
    return self.map { $0.toDomain() }
  }
}

public extension AttendanceDTOModel {
  func toDomain() -> [Attendance] {
    return self.data.toDomain()
  }
}
