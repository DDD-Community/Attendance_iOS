//
//  VoteParticipationDTO.swift
//  Model
//
//  Created by Roy on 6/11/26.
//

import Foundation

// MARK: - [운영진] 참여 현황 (GET /votes/{id}/participation)

public struct VoteParticipationDTO: Decodable {
  public let voteId: Int?
  public let title: String?
  public let status: String?
  public let totalMembers: Int?
  public let respondedMembers: Int?
  public let participationRate: Int?
}
