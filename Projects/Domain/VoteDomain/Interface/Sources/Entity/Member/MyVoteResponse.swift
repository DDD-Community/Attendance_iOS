//
//  MyVoteResponse.swift
//  Entity
//
//  Created by DDD on 6/11/26.
//

import Foundation

public struct MyVoteResponse: Equatable, Sendable {
  public let voteId: Int
  public let responded: Bool
  
  public init(
    voteId: Int,
    responded: Bool
  ) {
    self.voteId = voteId
    self.responded = responded
  }
}
