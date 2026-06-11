//
//  Vote.swift
//  Entity
//
//  Created by Roy on 6/11/26.
//

import Foundation

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
