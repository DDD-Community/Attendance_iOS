//
//  SelectTeamEntity.swift
//  OnBoardingDomainInterface
//
//  Created by DDD on 12/31/25.
//

import ProfileDomainInterface

public struct SelectTeamEntity: Equatable, Identifiable, Sendable {
  public var id: Int { teamId }
  public let teamId: Int
  public let teams: SelectTeams

  public init(teamId: Int, teams: SelectTeams) {
    self.teamId = teamId
    self.teams = teams
  }
}

public extension SelectTeamEntity {
  var toSelectTeam: SelectTeams? {
    teams == .unknown ? nil : teams
  }
}

public extension Array where Element == SelectTeamEntity {
  func orderedSelectTeams() -> [SelectTeams] {
    sorted { $0.teamId < $1.teamId }.compactMap(\.toSelectTeam)
  }
}
