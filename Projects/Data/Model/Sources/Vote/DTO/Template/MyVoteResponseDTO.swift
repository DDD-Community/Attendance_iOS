//
//  MyVoteResponseDTO.swift
//  Model
//
//  Created by Roy on 6/11/26.
//

import Foundation

public struct MyVoteResponseDTO: Decodable {
  public let voteId: Int?
  public let responded: Bool?
}
