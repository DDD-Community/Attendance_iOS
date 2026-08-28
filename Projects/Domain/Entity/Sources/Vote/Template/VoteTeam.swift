//
//  VoteTeam.swift
//  Entity
//
//  Created by DDD on 6/11/26.
//

import Foundation

// MARK: - [멤버] 팀 투표 대상 팀

public struct VoteTeam: Equatable, Identifiable, Sendable {
  public let id: Int
  public let name: String
  public let serviceName: String?
  public let isOwnTeam: Bool

  public init(
    id: Int,
    name: String,
    serviceName: String?,
    isOwnTeam: Bool
  ) {
    self.id = id
    self.name = name
    self.serviceName = serviceName
    self.isOwnTeam = isOwnTeam
  }
}
