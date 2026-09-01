//
//  FeedbackResultOptionDTO.swift
//  Model
//
//  Created by DDD on 6/11/26.
//

import Foundation

public struct FeedbackResultOptionDTO: Decodable, Sendable {
  public let optionId: String?
  public let label: String?
  public let count: Int?
}
