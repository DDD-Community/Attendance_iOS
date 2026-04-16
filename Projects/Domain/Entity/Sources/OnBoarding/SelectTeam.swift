//
//  SelectEntity.swift
//  Entity
//
//  Created by Wonji Suh  on 12/31/25.
//

import Foundation

// MARK: - 나중에
//SelectTeam 으로 이름 변경 예정
public struct SelectTeamEntity: Equatable, Identifiable {
  public var id: Int { teamId }
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


public extension SelectTeamEntity {
  var toSelectTeam: SelectTeams? {
    switch teams {
    case .and1: return .and1
    case .and2: return .and2
    case .ios1: return .ios1
    case .ios2: return .ios2
    case .web1: return .web1
    case .web2: return .web2
    case .unknown: return nil
    }
  }

}

extension Array where Element == SelectTeamEntity {
  public func orderedSelectTeams() -> [SelectTeams] {
    return self
      .sorted { $0.teamId < $1.teamId }
      .compactMap { $0.toSelectTeam }
  }
}
