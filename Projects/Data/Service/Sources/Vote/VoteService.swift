//
//  VoteService.swift
//  Service
//
//  Created by Roy on 6/11/26.
//

import Foundation

import API
import Foundations

import AsyncMoya

public enum VoteService {
  case list
  case detail(voteId: Int)
  case participation(voteId: Int)
  case nonResponders(voteId: Int)
  case open(voteId: Int)
  case close(voteId: Int)
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
    }
  }

  public var error: [Int: AsyncMoya.NetworkError]? {
    return nil
  }

  public var method: Moya.Method {
    switch self {
    case .list, .detail, .participation, .nonResponders:
      return .get
    case .open, .close:
      return .patch
    }
  }

  public var parameters: [String: Any]? {
    return nil
  }

  public var headers: [String: String]? {
    // TODO: 임시 토큰 헤더 — 실제 토큰 연동 후 APIHeader.baseHeader로 교체
    return APIHeader.voteTempHeader
  }
}
