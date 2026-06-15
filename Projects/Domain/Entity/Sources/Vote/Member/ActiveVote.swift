//
//  ActiveVote.swift
//  Entity
//
//  Created by Roy on 6/11/26.
//

import Foundation

// MARK: - [멤버] 진행 중 투표 / 내 참여 여부

public struct ActiveVote: Equatable, Sendable {
  public let voteId: Int
  public let title: String
  public let alreadyResponded: Bool
  
  public init(
    voteId: Int,
    title: String,
    alreadyResponded: Bool
  ) {
    self.voteId = voteId
    self.title = title
    self.alreadyResponded = alreadyResponded
  }
}
