//
//  DefaultAttendanceRepositoryImpl.swift
//  Repository
//
//  Created by Wonji Suh  on 7/23/25.
//

import Model
import Entity

final public class DefaultAttendanceRepositoryImpl: AttendanceInterface  {
  
  public init() {}


  public func adminAttendanceCount(scheduleId: Int) async throws -> Entity.AttendanceCount {
    return Entity.AttendanceCount(
      attendanceCount: 18,
      lateCount: 2,
      absentCount: 1
    )
  }

}

