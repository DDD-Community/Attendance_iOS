//
//  SelectEntity.swift
//  Entity
//
//  Created by Wonji Suh  on 12/31/25.
//

import Foundation

// MARK: - 나중에
//SelectTeam 으로 이름 변경 예정
public struct SelectTeamEntity: Equatable {
  public let teamId: Int
  public let teams: SelectTeams

  public init(
    teamId: Int,
    teams: SelectTeams
  ) {
    self.teamId = teamId
    self.teams = teams
  }
}
