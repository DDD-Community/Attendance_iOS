//
//  Vote.swift
//  Entity
//
//  Created by DDD on 6/11/26.
//

import Foundation

// MARK: - [운영진] 투표 목록/상세

public struct Vote: Equatable, Identifiable, Sendable {
  public let id: Int // voteId
  public let title: String
  public let status: VoteStatus

  public init(
    id: Int,
    title: String,
    status: VoteStatus
  ) {
    self.id = id
    self.title = title
    self.status = status
  }
}
