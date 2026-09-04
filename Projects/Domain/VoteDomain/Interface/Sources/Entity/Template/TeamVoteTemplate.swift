//
//  TeamVoteTemplate.swift
//  Entity
//
//  Created by DDD on 6/11/26.
//

import Foundation

// MARK: - [공통] 팀 투표 템플릿

public struct TeamVoteTemplate: Codable, Equatable, Sendable {
  public let title: String
  public let description: String
  public let notice: String
  public let categories: [TeamVoteCategory]

  public init(
    title: String,
    description: String,
    notice: String,
    categories: [TeamVoteCategory]
  ) {
    self.title = title
    self.description = description
    self.notice = notice
    self.categories = categories
  }
}
