//
//  VoteStatus.swift
//  Entity
//
//  Created by Roy on 6/11/26.
//

import Foundation

/// 운영진 투표 진행 상태
public enum VoteStatus: Equatable {
  case before // 투표 전
  case inProgress // 진행 중
  case after // 투표 종료
}
