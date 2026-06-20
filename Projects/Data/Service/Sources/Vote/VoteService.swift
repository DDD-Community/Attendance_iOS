//
//  VoteService.swift
//  Service
//
//  Created by Roy on 6/11/26.
//

import Foundation

import API
import Entity
import Foundations

import AsyncMoya

public enum VoteService {
  // 운영진
  case list
  case create(body: CreateVoteInput)
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
  case submit(voteId: Int, body: VoteSubmission)
  case myResponse(voteId: Int)
}

extension VoteService: BaseTargetType {
  public typealias Domain = AttendanceDomain

  public var domain: AttendanceDomain {
    return .vote
  }

  public var urlPath: String {
    switch self {
    case .list:
      return VoteAPI.list.description
    case .create:
      return VoteAPI.create.description
    case let .detail(voteId):
      return VoteAPI.detail(voteId: voteId).description
    case let .participation(voteId):
      return VoteAPI.participation(voteId: voteId).description
    case let .nonResponders(voteId):
      return VoteAPI.nonResponders(voteId: voteId).description
    case let .open(voteId):
      return VoteAPI.open(voteId: voteId).description
    case let .close(voteId):
      return VoteAPI.close(voteId: voteId).description
    case let .teamVoteResults(voteId):
      return VoteAPI.teamVoteResults(voteId: voteId).description
    case let .feedbackResults(voteId):
      return VoteAPI.feedbackResults(voteId: voteId).description
    case .active:
      return VoteAPI.active.description
    case let .teamVoteTemplate(voteId):
      return VoteAPI.teamVoteTemplate(voteId: voteId).description
    case let .feedbackTemplate(voteId):
      return VoteAPI.feedbackTemplate(voteId: voteId).description
    case let .submit(voteId, _):
      return VoteAPI.submit(voteId: voteId).description
    case let .myResponse(voteId):
      return VoteAPI.myResponse(voteId: voteId).description
    }
  }

  public var error: [Int: AsyncMoya.NetworkError]? {
    return nil
  }

  public var method: Moya.Method {
    switch self {
    case .list, .detail, .participation, .nonResponders,
         .teamVoteResults, .feedbackResults,
         .active, .teamVoteTemplate, .feedbackTemplate, .myResponse:
      return .get
    case .open, .close:
      return .patch
    case .create, .submit:
      return .post
    }
  }

  public var parameters: [String: Any]? {
    switch self {
    case let .create(body):
      return body.toDictionary
    case let .submit(_, body):
      return body.toDictionary
    default:
      return nil
    }
  }

  public var headers: [String: String]? {
    // TODO: 임시 토큰 헤더 — 실제 토큰 연동 후 APIHeader.baseHeader로 교체
    switch self {
    case .active, .teamVoteTemplate, .feedbackTemplate, .submit, .myResponse:
      return APIHeader.baseHeader
    default:
      return APIHeader.baseHeader
    }
  }
}
