//
//  ActiveVoteDTO.swift
//  Model
//
//  Created by DDD on 6/11/26.
//

import Foundation

// MARK: - [멤버] 진행 중 투표 / 내 참여 여부

public struct ActiveVoteDTO: Decodable, Sendable {
  public let voteId: Int?
  public let title: String?
  public let alreadyResponded: Bool?
}
