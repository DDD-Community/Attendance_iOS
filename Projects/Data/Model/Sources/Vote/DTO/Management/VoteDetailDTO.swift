//
//  VoteDetailDTO.swift
//  Model
//
//  Created by Roy on 6/11/26.
//

import Foundation

// MARK: - [운영진] 투표 상세 (GET /votes/{id})

public struct VoteDetailDTO: Decodable {
  public let voteId: Int?
  public let title: String?
  public let status: String?
}
