//
//  MockMyPageRepository.swift
//  DomainInterface
//
//  Created by DDD on 1/12/26.
//

import Entity

public final class MockMyPageRepository: MyPageInterface {
  public init() {}

  public func fetchAttendances() async throws(MyPageError) -> AttendanceSummaryResponse {
    .init(
      totalAttended: 0,
      totalLate: 0,
      totalAbsent: 0
    )
  }

  public func fetchSchedules() async throws(MyPageError) -> [AttendanceMyScheduleResponse] {
    [
      .init(
        id: 1,
        name: "제목입니다.",
        desc: "내용입니다.",
        month: 12,
        day: 25,
        status: "LATE"
      )
    ]
  }
}
