//
//  TeamVoteRankDTO.swift
//  VoteDomain
//
//  Created by DDD on 6/11/26.
//

import Foundation

public struct TeamVoteRankDTO: Decodable, Sendable {
  public let rank: Int?
  public let teamId: Int?
  public let name: String?
  public let serviceName: String?
  public let voteCount: Int?
}
