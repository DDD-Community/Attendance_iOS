//
//  TeamVoteTemplateInfo.swift
//  Entity
//
//  Created by Roy on 6/11/26.
//

import Foundation

// MARK: - [멤버] 팀 투표 템플릿 응답

public struct TeamVoteTemplateInfo: Equatable, Sendable {
  public let templateVersion: Int
  public let status: VoteStatus
  public let template: TeamVoteTemplate
  public let teams: [VoteTeam]

  public init(
    templateVersion: Int,
    status: VoteStatus,
    template: TeamVoteTemplate,
    teams: [VoteTeam]
  ) {
    self.templateVersion = templateVersion
    self.status = status
    self.template = template
    self.teams = teams
  }
}
