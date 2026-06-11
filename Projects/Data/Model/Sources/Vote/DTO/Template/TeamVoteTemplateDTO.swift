//
//  TeamVoteTemplateDTO.swift
//  Model
//
//  Created by Roy on 6/11/26.
//

import Foundation

// MARK: - [공통] 팀 투표 템플릿

public struct TeamVoteTemplateDTO: Codable {
  public let title: String?
  public let description: String?
  public let notice: String?
  public let categories: [TeamVoteCategoryDTO]?

  public init(
    title: String?,
    description: String?,
    notice: String?,
    categories: [TeamVoteCategoryDTO]?
  ) {
    self.title = title
    self.description = description
    self.notice = notice
    self.categories = categories
  }
}
