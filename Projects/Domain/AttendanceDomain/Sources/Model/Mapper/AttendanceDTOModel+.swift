//
//  AttendanceDTOModel+.swift
//  AttendanceDomain
//
//  Created by DDD on 1/11/26.
//

import AttendanceDomainInterface

public extension AttendanceDTOResponse {
  func toDomain() -> Attendance {
    return Attendance(
      id: self.attendanceID,
      userID: "\(self.userID)",
      userName: self.userName,
      userInfo: self.userInfo,
      status: AttendanceStatus.from(apiKey: self.attendanceStatus) ?? .defaults
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
