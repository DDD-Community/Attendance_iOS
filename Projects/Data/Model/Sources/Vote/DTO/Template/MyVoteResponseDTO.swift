//
//  MyVoteResponseDTO.swift
//  Model
//
//  Created by DDD on 6/11/26.
//

import Foundation

public struct MyVoteResponseDTO: Decodable {
  public let voteId: Int?
  public let responded: Bool?
}
