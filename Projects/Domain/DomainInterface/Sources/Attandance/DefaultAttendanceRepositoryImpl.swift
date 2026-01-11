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
        id: "1L",
        userID: "1L",
        userName: "홍길동",
        userInfo: "Web1팀/BE",
        status: .late
      ),
      Entity.Attendance(
        id: "2A",
        userID: "2A",
        userName: "김민지",
        userInfo: "Web1팀/FE",
        status: .attended
      ),
      Entity.Attendance(
        id: "3B",
        userID: "3B",
        userName: "이서준",
        userInfo: "Web1팀/BE",
        status: .absent
      ),
      Entity.Attendance(
        id: "4C",
        userID: "4C",
        userName: "박지훈",
        userInfo: "Web1팀/FE",
        status: .attended
      )
      )
    ]
  }

}
