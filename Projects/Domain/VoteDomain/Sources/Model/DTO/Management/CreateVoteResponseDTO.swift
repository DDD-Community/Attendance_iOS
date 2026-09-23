//
//  CreateVoteResponseDTO.swift
//  VoteDomain
//
//  Created by DDD on 6/11/26.
//

import Foundation

// MARK: - [운영진] 투표 생성 응답 (POST /votes)

public struct CreateVoteResponseDTO: Decodable, Sendable {
  public let voteId: Int?
}
