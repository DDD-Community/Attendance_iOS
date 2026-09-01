//
//  VoteAPI.swift
//  API
//
//  Created by DDD on 6/11/26.
//

import Foundation

public enum VoteAPI {
  // 운영진
  case list
  case create
  case detail(voteId: Int)
  case participation(voteId: Int)
  case nonResponders(voteId: Int)
  case open(voteId: Int)
  case close(voteId: Int)
  case teamVoteResults(voteId: Int)
  case feedbackResults(voteId: Int)
  // 멤버
  case active
  case teamVoteTemplate(voteId: Int)
  case feedbackTemplate(voteId: Int)
  case submit(voteId: Int)
  case myResponse(voteId: Int)

  public var description: String {
    switch self {
    case .list, .create:
      return ""
    case .active:
      return "/active"
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
    case let .teamVoteResults(voteId):
      return "/\(voteId)/team-vote/results"
    case let .feedbackResults(voteId):
      return "/\(voteId)/feedback/results"
    case let .teamVoteTemplate(voteId):
      return "/\(voteId)/team-vote/template"
    case let .feedbackTemplate(voteId):
      return "/\(voteId)/feedback/template"
    case let .submit(voteId):
      return "/\(voteId)/responses"
    case let .myResponse(voteId):
      return "/\(voteId)/responses/me"
    }
  }
}
