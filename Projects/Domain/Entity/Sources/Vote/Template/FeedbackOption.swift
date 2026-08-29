//
//  FeedbackOption.swift
//  Entity
//
//  Created by DDD on 6/11/26.
//

import Foundation

public struct FeedbackOption: Codable, Equatable, Identifiable, Sendable {
  public let id: String
  public let label: String

  public init(
    id: String,
    label: String
  ) {
    self.id = id
    self.label = label
  }
}
