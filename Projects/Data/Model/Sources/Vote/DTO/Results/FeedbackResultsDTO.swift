//
//  FeedbackResultsDTO.swift
//  Model
//
//  Created by DDD on 6/11/26.
//

import Foundation

// MARK: - [운영진] 피드백 결과 집계

public struct FeedbackResultsDTO: Decodable, Sendable {
  public let voteId: Int?
  public let totalResponses: Int?
  public let questions: [FeedbackResultQuestionDTO]?
}
