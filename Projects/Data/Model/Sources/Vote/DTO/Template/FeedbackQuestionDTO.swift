//
//  FeedbackQuestionDTO.swift
//  Model
//
//  Created by Roy on 6/11/26.
//

import Foundation

public struct FeedbackQuestionDTO: Codable {
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
}
