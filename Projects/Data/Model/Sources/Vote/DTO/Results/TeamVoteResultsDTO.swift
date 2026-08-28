//
//  TeamVoteResultsDTO.swift
//  Model
//
//  Created by DDD on 6/11/26.
//

import Foundation

// MARK: - [운영진] 팀 투표 결과 집계

public struct TeamVoteResultsDTO: Decodable {
  public let voteId: Int?
  public let title: String?
  public let status: String?
  public let totalResponses: Int?
  public let categories: [TeamVoteResultCategoryDTO]?
}
