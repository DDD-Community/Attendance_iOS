//
//  FeedbackResultQuestion.swift
//  Entity
//
//  Created by Roy on 6/11/26.
//

import Foundation

public struct FeedbackResultQuestion: Equatable, Identifiable, Sendable {
  public let id: String
  public let title: String
  public let type: VoteComponentType
  public let order: Int
  public let options: [FeedbackResultOption]?
  public let trueCount: Int?
  public let falseCount: Int?
  public let textAnswers: [String]?

  public init(
    id: String,
    title: String,
    type: VoteComponentType,
    order: Int,
    options: [FeedbackResultOption]?,
    trueCount: Int?,
    falseCount: Int?,
    textAnswers: [String]?
  ) {
    self.id = id
    self.title = title
    self.type = type
    self.order = order
    self.options = options
    self.trueCount = trueCount
    self.falseCount = falseCount
    self.textAnswers = textAnswers
  }
}
