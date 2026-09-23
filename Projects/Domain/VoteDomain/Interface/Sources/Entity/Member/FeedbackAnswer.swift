//
//  FeedbackAnswer.swift
//  Entity
//
//  Created by DDD on 6/11/26.
//

import Foundation

public struct FeedbackAnswer: Codable, Equatable, Sendable {
  public let questionId: String
  public let optionIds: [String]?
  public let textValue: String?
  public let boolValue: Bool?
  
  public init(
    questionId: String,
    optionIds: [String]?,
    textValue: String?,
    boolValue: Bool?
  ) {
    self.questionId = questionId
    self.optionIds = optionIds
    self.textValue = textValue
    self.boolValue = boolValue
  }
}
