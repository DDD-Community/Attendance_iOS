//
//  TeamVoteCategory.swift
//  Entity
//
//  Created by DDD on 6/11/26.
//

import Foundation

public struct TeamVoteCategory: Codable, Equatable, Identifiable, Sendable {
  public let id: String
  public let order: Int
  public let title: String
  public let maxSelectableTeams: Int
  public let reasonRequired: Bool
  public let reasonMinLength: Int
  public let reasonMaxLength: Int
  public let reasonLabel: String

  public init(
    id: String,
    order: Int,
    title: String,
    maxSelectableTeams: Int,
    reasonRequired: Bool,
    reasonMinLength: Int,
    reasonMaxLength: Int,
    reasonLabel: String
  ) {
    self.id = id
    self.order = order
    self.title = title
    self.maxSelectableTeams = maxSelectableTeams
    self.reasonRequired = reasonRequired
    self.reasonMinLength = reasonMinLength
    self.reasonMaxLength = reasonMaxLength
    self.reasonLabel = reasonLabel
  }
}
