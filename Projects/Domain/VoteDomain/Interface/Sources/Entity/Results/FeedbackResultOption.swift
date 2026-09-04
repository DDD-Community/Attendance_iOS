//
//  FeedbackResultOption.swift
//  Entity
//
//  Created by DDD on 6/11/26.
//

import Foundation

public struct FeedbackResultOption: Equatable, Identifiable, Sendable {
  public let id: String
  public let label: String
  public let count: Int

  public init(
    optionId: String,
    label: String,
    count: Int
  ) {
    id = optionId
    self.label = label
    self.count = count
  }
}
