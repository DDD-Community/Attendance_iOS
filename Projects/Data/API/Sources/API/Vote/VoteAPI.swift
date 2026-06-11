//
//  VoteAPI.swift
//  API
//
//  Created by Roy on 6/11/26.
//

import Foundation

public enum VoteAPI {
  case list
  case detail(voteId: Int)
  case participation(voteId: Int)
  case nonResponders(voteId: Int)
  case open(voteId: Int)
  case close(voteId: Int)

  public var description: String {
    switch self {
    case .list:
      return ""
    case let .detail(voteId):
      return "/\(voteId)"
    case let .participation(voteId):
      return "/\(voteId)/participation"
    case let .nonResponders(voteId):
      return "/\(voteId)/non-responders"
    case let .open(voteId):
      return "/\(voteId)/open"
    case let .close(voteId):
      return "/\(voteId)/close"
    }
  }
}
