//
//  TeamVoteResultCategoryDTO.swift
//  Model
//
//  Created by DDD on 6/11/26.
//

import Foundation

public struct TeamVoteResultCategoryDTO: Decodable, Sendable {
  public let categoryId: String?
  public let title: String?
  public let order: Int?
  public let teams: [TeamVoteRankDTO]?
  public let reasons: [String]?
}
