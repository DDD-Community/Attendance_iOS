//
//  FeedbackTemplateDTO.swift
//  Model
//
//  Created by DDD on 6/11/26.
//

import Foundation

// MARK: - [공통] 피드백 템플릿

public struct FeedbackTemplateDTO: Codable, Sendable {
  public let title: String?
  public let description: String?
  public let questions: [FeedbackQuestionDTO]?

  public init(
    title: String?,
    description: String?,
    questions: [FeedbackQuestionDTO]?
  ) {
    self.title = title
    self.description = description
    self.questions = questions
  }
}
