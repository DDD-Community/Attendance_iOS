//
//  SelectTeamEntity+Mapping.swift
//  Presentation
//
//  Created by Wonji Suh  on 1/11/26.
//

import Entity
import Model
import ComposableArchitecture

extension SelectTeamEntity {
  var toSelectTeam: SelectTeam? {
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

extension IdentifiedArrayOf where Element == SelectTeamEntity {
  func orderedSelectTeams() -> [SelectTeam] {
    return self
      .sorted { $0.teamId < $1.teamId }
      .compactMap { $0.toSelectTeam }
  }
}
