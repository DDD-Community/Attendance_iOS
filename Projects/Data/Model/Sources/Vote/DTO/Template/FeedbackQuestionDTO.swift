//
//  FeedbackQuestionDTO.swift
//  Model
//
//  Created by DDD on 6/11/26.
//

import Foundation

public struct FeedbackQuestionDTO: Codable, Sendable {
  public let id: String?
  public let order: Int?
  public let type: String?
  public let title: String?
  public let helpText: String?
  public let required: Bool?
  public let maxSelectableOptions: Int?
  public let maxLength: Int?
  public let options: [FeedbackOptionDTO]?
  public let followUp: [FeedbackQuestionDTO]?

  private enum CodingKeys: String, CodingKey {
    case id
    case order
    case type
    case title
    case helpText
    case required
    case maxSelectableOptions
    case maxLength
    case options
    case followUp
  }

  public init(
    id: String?,
    order: Int?,
    type: String?,
    title: String?,
    helpText: String?,
    required: Bool?,
    maxSelectableOptions: Int?,
    maxLength: Int?,
    options: [FeedbackOptionDTO]?,
    followUp: [FeedbackQuestionDTO]?
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

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    id = try container.decodeIfPresent(String.self, forKey: .id)
    order = try container.decodeIfPresent(Int.self, forKey: .order)
    type = try container.decodeIfPresent(String.self, forKey: .type)
    title = try container.decodeIfPresent(String.self, forKey: .title)
    helpText = try container.decodeIfPresent(String.self, forKey: .helpText)
    required = try container.decodeIfPresent(Bool.self, forKey: .required)
    maxSelectableOptions = try container.decodeIfPresent(Int.self, forKey: .maxSelectableOptions)
    maxLength = try container.decodeIfPresent(Int.self, forKey: .maxLength)
    options = try container.decodeIfPresent([FeedbackOptionDTO].self, forKey: .options)

    if let followUpItems = try? container.decodeIfPresent([FeedbackQuestionDTO].self, forKey: .followUp) {
      followUp = followUpItems
    } else if let followUpItem = try? container.decodeIfPresent(FeedbackQuestionDTO.self, forKey: .followUp) {
      followUp = [followUpItem]
    } else {
      followUp = nil
    }
  }
}
