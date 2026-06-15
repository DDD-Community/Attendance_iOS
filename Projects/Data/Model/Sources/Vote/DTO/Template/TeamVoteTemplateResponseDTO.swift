//
//  TeamVoteTemplateResponseDTO.swift
//  Model
//
//  Created by Roy on 6/11/26.
//

import Foundation

// MARK: - [멤버] 팀 투표 템플릿 응답 (GET /votes/{id}/team-vote/template)

public struct TeamVoteTemplateResponseDTO: Decodable {
  public let templateVersion: Int?
  public let status: String?
  public let template: TeamVoteTemplateDTO?
  public let teams: [VoteTeamDTO]?
}
