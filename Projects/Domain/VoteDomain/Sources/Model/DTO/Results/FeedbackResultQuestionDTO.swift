//
//  FeedbackResultQuestionDTO.swift
//  VoteDomain
//
//  Created by DDD on 6/11/26.
//

import Foundation

public struct FeedbackResultQuestionDTO: Decodable, Sendable {
  public let questionId: String?
  public let title: String?
  public let type: String?
  public let order: Int?
  public let options: [FeedbackResultOptionDTO]?
  public let trueCount: Int?
  public let falseCount: Int?
  public let textAnswers: [String]?
}
