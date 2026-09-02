//
//  DefaultAttendanceRepositoryImpl.swift
//  Repository
//
//  Created by DDD on 7/23/25.
//

// Entity 모듈 없이 구현
import Entity

final public class DefaultAttendanceRepositoryImpl: AttendanceInterface {
  public init() {}

  public func adminAttendanceCount(scheduleId: Int) async throws(AttendanceError) -> AttendanceCount {
    // Mock: sessionAttendance 데이터와 일치하도록 수정
    // attended: 2명 (김민지, 박지훈), late: 1명 (홍길동), absent: 1명 (이서준)

    let result = AttendanceCount(
      attendanceCount: 2,  // 출석 인원
      lateCount: 1,        // 지각 인원
      absentCount: 1       // 결석 인원
    )

    return result
  }

  public func fetchAttendanceTeams() async throws(AttendanceError) -> [SelectTeamEntity] {
    return [
      SelectTeamEntity(teamId: 1, teams: .ios1),
      SelectTeamEntity(teamId: 2, teams: .ios2),
      SelectTeamEntity(teamId: 3, teams: .and1),
      SelectTeamEntity(teamId: 4, teams: .and2),
      SelectTeamEntity(teamId: 5, teams: .web1),
      SelectTeamEntity(teamId: 6, teams: .web2),
    ]
  }

  public func sessionAttendance(
    scheduleId: Int,
    teamId: Int
  ) async throws(AttendanceError) -> [Attendance] {

    let result = [
      Attendance(
        id: 1,
        userID: "1",
        userName: "홍길동",
        userInfo: "Web1팀/BE",
        status: .late
      ),
      Attendance(
        id: 2,
        userID: "2",
        userName: "김민지",
        userInfo: "Web1팀/FE",
        status: .attended
      ),
      Attendance(
        id: 3,
        userID: "3",
        userName: "이서준",
        userInfo: "Web1팀/BE",
        status: .absent
      ),
      Attendance(
        id: 4,
        userID: "4",
        userName: "박지훈",
        userInfo: "Web1팀/FE",
        status: .attended
      )
    ]

    return result
  }

  public func fetchStatus() async throws(AttendanceError) -> [AttendanceStatus] {
    return [
      .attended,   // 출석
      .late,      // 지각
      .absent     // 결석
    ]
  }

  public func editAttendance(input: EditAttendanceInput) async throws(AttendanceError) -> EditAttendance {
    // Mock: 출석 상태 변경 성공
    // 실제로는 API 호출하여 변경하지만, mock에서는 성공 응답만 반환

    // 짧은 지연으로 실제 API 호출 시뮬레이션
    try? await Task.sleep(for: .milliseconds(500))

    return EditAttendance(
      isSuccess: true,
      code: "SUCCESS",
      message: "출석 상태가 성공적으로 변경되었습니다.",
      detail: "attendanceId: \(input.attendanceId), 새로운 상태: \(input.status)"
    )
  }

}
