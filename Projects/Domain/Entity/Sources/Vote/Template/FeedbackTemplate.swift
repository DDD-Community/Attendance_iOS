//
//  FeedbackTemplate.swift
//  Entity
//
//  Created by Roy on 6/11/26.
//

import Foundation

// MARK: - [공통] 피드백 템플릿

public struct FeedbackTemplate: Codable, Equatable, Sendable {
  public let title: String
  public let description: String
  public let questions: [FeedbackQuestion]

  public init(
    title: String,
    description: String,
    questions: [FeedbackQuestion]
  ) {
    self.title = title
    self.description = description
    self.questions = questions
  }
}
