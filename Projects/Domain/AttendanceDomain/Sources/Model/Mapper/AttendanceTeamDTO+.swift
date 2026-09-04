//
//  AttendanceTeamDTO+.swift
//  AttendanceDomain
//
//  Created by DDD on 9/3/26.
//

import OnBoardingDomainInterface

extension Array where Element == AttendanceTeamDTO {
  func toDomain() -> [SelectTeamEntity] {
    map {
      SelectTeamEntity(
        teamId: $0.teamId,
        teams: SelectTeams(rawValue: $0.name) ?? .unknown
      )
    }
  }
}
