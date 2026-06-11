//
//  VoteError.swift
//  Entity
//
//  Created by Roy on 6/11/26.
//

import Foundation

public enum VoteError: LocalizedError, Equatable {
  case noActiveVote
  case notFound
  case managerOnly
  case invalidStatus
  case alreadyOpen
  case unauthorized
  case serverError(Int)
  case unknown(String)

  public var errorDescription: String? {
    switch self {
    case .noActiveVote:
      return "진행 중인 투표가 없습니다"
    case .notFound:
      return "존재하지 않는 투표입니다"
    case .managerOnly:
      return "운영진만 접근할 수 있습니다"
    case .invalidStatus:
      return "잘못된 투표 상태 전이입니다"
    case .alreadyOpen:
      return "이미 진행 중인 투표가 있습니다"
    case .unauthorized:
      return "로그인이 필요합니다"
    case let .serverError(code):
      return "서버 오류 (코드: \(code))"
    case let .unknown(message):
      return message
    }
  }

  public var failureReason: String? {
    switch self {
    case .noActiveVote:
      return "아직 시작된 투표가 없어요"
    case .notFound:
      return "삭제되었거나 잘못된 투표예요"
    case .managerOnly:
      return "운영진 권한이 필요해요"
    case .invalidStatus:
      return "현재 상태에서는 처리할 수 없어요"
    case .alreadyOpen:
      return "한 기수에는 하나의 투표만 진행할 수 있어요"
    case .unauthorized:
      return "로그인이 필요해요"
    case .serverError:
      return "잠시 후 다시 시도해주세요"
    case .unknown:
      return "예상치 못한 오류가 발생했어요"
    }
  }

  public var recoverySuggestion: String? {
    switch self {
    case .noActiveVote, .notFound:
      return "새로고침 후 다시 확인해주세요"
    case .managerOnly, .unauthorized:
      return "다시 로그인하거나 권한을 확인해주세요"
    case .invalidStatus, .alreadyOpen:
      return "투표 상태를 새로고침한 뒤 다시 시도해주세요"
    case .serverError, .unknown:
      return "잠시 후 다시 시도하거나 문제가 지속되면 문의해주세요"
    }
  }

  public static func from(_ error: Error) -> VoteError {
    if let voteError = error as? VoteError {
      return voteError
    }
    return .unknown(error.localizedDescription)
  }

  public static func from(statusCode: Int, code: String?, message: String? = nil) -> VoteError {
    switch code {
    case "VOTE_NO_ACTIVE":
      return .noActiveVote
    case "DATA_NOT_FOUND", "VOTE_NOT_FOUND":
      return .notFound
    case "MANAGER_ONLY", "VOTE_MANAGER_NOT_ALLOWED":
      return .managerOnly
    case "AUTH_EXPIRED_TOKEN":
      return .unauthorized
    case "VOTE_ALREADY_OPEN":
      return .alreadyOpen
    case "VOTE_INVALID_STATUS", "VOTE_NOT_DRAFT", "VOTE_NOT_OPEN", "VALIDATION_ERROR":
      return .invalidStatus
    case "INTERNAL_SERVER_ERROR":
      return .serverError(statusCode)
    default:
      break
    }

    switch statusCode {
    case 401:
      return .unauthorized
    case 403:
      return .managerOnly
    case 404:
      return .notFound
    case 500 ... 599:
      return .serverError(statusCode)
    default:
      return .unknown(message ?? "알 수 없는 오류가 발생했습니다")
    }
  }
}
