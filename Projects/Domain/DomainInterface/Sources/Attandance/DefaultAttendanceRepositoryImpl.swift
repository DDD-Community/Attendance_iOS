//
//  DefaultAttendanceRepositoryImpl.swift
//  Repository
//
//  Created by Wonji Suh  on 7/23/25.
//

// Entity 모듈 없이 구현
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

  public func fetchAttendanceTeams() async throws -> [Entity.SelectTeamEntity] {
    return [
      Entity.SelectTeamEntity(teamId: 1, teams: .ios1),
      Entity.SelectTeamEntity(teamId: 2, teams: .ios2),
      Entity.SelectTeamEntity(teamId: 3, teams: .and1),
      Entity.SelectTeamEntity(teamId: 4, teams: .and2),
      Entity.SelectTeamEntity(teamId: 5, teams: .web1),
      Entity.SelectTeamEntity(teamId: 6, teams: .web2),
    ]
  }

  public func sessionAttendance(
    scheduleId: Int,
    teamId: Int
  ) async throws -> [Entity.Attendance] {
    return [
      Entity.Attendance(
        id: 1,
        userID: "1",
        userName: "홍길동",
        userInfo: "Web1팀/BE",
        status: .late
      ),
      Entity.Attendance(
        id: 2,
        userID: "2",
        userName: "김민지",
        userInfo: "Web1팀/FE",
        status: .attended
      ),
      Entity.Attendance(
        id: 3,
        userID: "3",
        userName: "이서준",
        userInfo: "Web1팀/BE",
        status: .absent
      ),
      Entity.Attendance(
        id: 4,
        userID: "4",
        userName: "박지훈",
        userInfo: "Web1팀/FE",
        status: .attended
      )
    ]
  }

  public func fetchStatus() async throws -> [Entity.AttendanceStatus] {
    return [
      .attended,  // 출석
      .late,      // 지각
      .absent     // 결석
    ]
  }

  public func editAttendance(input: Entity.EditAttendanceInput) async throws -> Entity.EditAttendance {
    // Mock: 출석 상태 변경 성공
    // 실제로는 API 호출하여 변경하지만, mock에서는 성공 응답만 반환
    print("🔄 [MOCK] 출석 상태 변경 - attendanceId: \(input.attendanceId), status: \(input.status.desc), userId: \(input.userId)")

    // 짧은 지연으로 실제 API 호출 시뮬레이션
    try await Task.sleep(for: .milliseconds(500))

    return Entity.EditAttendance(
      isSuccess: true,
      code: "SUCCESS",
      message: "출석 상태가 성공적으로 변경되었습니다.",
      detail: "attendanceId: \(input.attendanceId), 새로운 상태: \(input.status.desc)"
    )
  }

}
