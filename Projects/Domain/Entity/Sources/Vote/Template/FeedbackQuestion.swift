//
//  FeedbackQuestion.swift
//  Entity
//
//  Created by Roy on 6/11/26.
//

import Foundation

public struct FeedbackQuestion: Codable, Equatable, Identifiable, Sendable {
  public let id: String
  public let order: Int
  public let type: VoteComponentType
  public let title: String
  public let helpText: String?
  public let required: Bool
  public let maxSelectableOptions: Int?
  public let maxLength: Int?
  public let options: [FeedbackOption]?
  public let followUp: [FeedbackQuestion]

  public init(
    id: String,
    order: Int,
    type: VoteComponentType,
    title: String,
    helpText: String?,
    required: Bool,
    maxSelectableOptions: Int?,
    maxLength: Int?,
    options: [FeedbackOption]?,
    followUp: [FeedbackQuestion]
  ) {
    self.id = id
    self.order = order
    self.type = type
    self.title = title
    self.helpText = helpText
    self.required = required
    self.maxSelectableOptions = maxSelectableOptions
    self.maxLength = maxLength
    self.options = options
    self.followUp = followUp
  }
}
