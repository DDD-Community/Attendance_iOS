//
//  VoteListItemDTO.swift
//  Model
//
//  Created by DDD on 6/11/26.
//

import Foundation

// MARK: - [운영진] 투표 목록 (GET /votes)

public struct VoteListItemDTO: Decodable, Sendable {
  public let voteId: Int?
  public let title: String?
  public let status: String?
  public let openedAt: String?
  public let closedAt: String?
  public let createdDate: String?
}
