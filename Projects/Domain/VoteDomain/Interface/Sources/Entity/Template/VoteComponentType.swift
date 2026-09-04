//
//  VoteComponentType.swift
//  Entity
//
//  Created by DDD on 6/11/26.
//

import Foundation

// MARK: - [공통] SDUI 컴포넌트 타입

public enum VoteComponentType: String, Codable, Equatable, Sendable {
  case teamSelect = "TEAM_SELECT"
  case multiSelect = "MULTI_SELECT"
  case longText = "LONG_TEXT"
  case boolean = "BOOLEAN"
}
