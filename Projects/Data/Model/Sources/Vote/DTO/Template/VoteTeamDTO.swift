//
//  VoteTeamDTO.swift
//  Model
//
//  Created by DDD on 6/11/26.
//

import Foundation

// MARK: - [멤버] 팀 투표 대상 팀

public struct VoteTeamDTO: Decodable {
  public let teamId: Int?
  public let name: String?
  public let serviceName: String?
  public let isOwnTeam: Bool?
}
