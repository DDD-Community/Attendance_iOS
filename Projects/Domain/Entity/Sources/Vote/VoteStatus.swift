//
//  VoteStatus.swift
//  Entity
//
//  Created by Roy on 6/11/26.
//

import Foundation

public enum VoteStatus: Equatable, Sendable {
  case before // 투표 전
  case inProgress // 진행 중
  case after // 투표 종료

  /// 서버 상태(DRAFT/OPEN/CLOSED) → UI 상태 매핑
  public init(serverStatus: String) {
    switch serverStatus.uppercased() {
    case "OPEN":
      self = .inProgress
    case "CLOSED":
      self = .after
    default: // DRAFT
      self = .before
    }
  }
}
