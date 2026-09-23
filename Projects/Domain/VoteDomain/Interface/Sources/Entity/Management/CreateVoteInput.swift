//
//  CreateVoteInput.swift
//  Entity
//
//  Created by DDD on 6/11/26.
//

import Foundation

// MARK: - [운영진] 투표 생성 입력 (POST /votes)

public struct CreateVoteInput: Codable, Equatable, Sendable {
  public let generationId: Int
  public let title: String
  public let teamVoteTemplate: TeamVoteTemplate?
  public let feedbackTemplate: FeedbackTemplate?
  
  public init(
    generationId: Int,
    title: String,
    teamVoteTemplate: TeamVoteTemplate?,
    feedbackTemplate: FeedbackTemplate?
  ) {
    self.generationId = generationId
    self.title = title
    self.teamVoteTemplate = teamVoteTemplate
    self.feedbackTemplate = feedbackTemplate
  }
}
