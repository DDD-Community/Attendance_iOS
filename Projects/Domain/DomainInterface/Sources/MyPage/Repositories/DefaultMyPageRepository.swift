//
//  DefaultMyPageRepository.swift
//  DomainInterface
//
//  Created by DDD on 1/12/26.
//

import Foundation

import Entity

final public class DefaultMyPageRepository: MyPageRepositoryInterface {
  public func fetchAttendances() async throws(MyPageError) -> AttendanceSummaryResponse {
    return .init(
      totalAttended: 0,
      totalLate: 0,
      totalAbsent: 0
    )
  }
  
  public func fetchSchedules() async throws(MyPageError) -> [AttendanceMyScheduleResponse] {
    return [
      .init(
        id: 1,
        name: "제목입니다.",
        desc: "내용입니다.",
        month: 12,
        day: 25,
        status: "LATE",
      )
    ]
  }
}
