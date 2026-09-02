//
//  VoteError.swift
//  Entity
//
//  Created by DDD on 6/11/26.
//

import Foundation

// MARK: - [공통] 투표 에러 (운영진/멤버 공용)

/// 투표 도메인의 실패만 담는다.
/// 인증 만료(401)는 DDDAuthenticator 가 토큰 갱신으로 흡수하고,
/// 5xx·전송·디코딩 실패는 도메인이 구분하지 않고 `.unknown` 으로 모은다.
public enum VoteError: LocalizedError, Equatable {
  case noActiveVote
  case notFound
  case managerOnly
  case invalidStatus
  case alreadyOpen
  case requestFailed
  case invalidResponse
  case unknown

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
    case .requestFailed:
      return "투표 요청을 처리하지 못했습니다"
    case .invalidResponse:
      return "투표 응답을 처리하지 못했습니다"
    case .unknown:
      return "알 수 없는 오류가 발생했습니다"
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
    case .requestFailed:
      return "투표 요청에 실패했어요"
    case .invalidResponse:
      return "투표 응답 형식이 올바르지 않아요"
    case .unknown:
      return "예상치 못한 오류가 발생했어요"
    }
  }

  public var recoverySuggestion: String? {
    switch self {
    case .noActiveVote, .notFound:
      return "새로고침 후 다시 확인해주세요"
    case .managerOnly:
      return "다시 로그인하거나 권한을 확인해주세요"
    case .invalidStatus, .alreadyOpen:
      return "투표 상태를 새로고침한 뒤 다시 시도해주세요"
    case .requestFailed, .invalidResponse:
      return "잠시 후 다시 시도해주세요"
    case .unknown:
      return "잠시 후 다시 시도하거나 문제가 지속되면 문의해주세요"
    }
  }

  /// 이미 도메인 에러인 값을 그대로 통과시킨다.
  /// Repository 가 `throws(VoteError)` 로 던지므로 여기서는 캐스팅만 하고,
  /// 그 밖의 에러는 전송 실패로 보고 `.unknown` 으로 흡수한다.
  public static func from(_ error: any Error) -> VoteError {
    (error as? VoteError) ?? .unknown
  }

  /// 서버가 내려준 에러 코드를 도메인 케이스로 옮긴다.
  /// 코드로 못 가리면 HTTP status 로 한 번 더 시도하고, 그래도 없으면 `.unknown` 이다.
  public static func from(
    statusCode: Int,
    code: String?,
    message _: String? = nil
  ) -> VoteError {
    switch code {
    case "VOTE_NO_ACTIVE":
      return .noActiveVote
    case "DATA_NOT_FOUND", "VOTE_NOT_FOUND":
      return .notFound
    case "MANAGER_ONLY", "VOTE_MANAGER_NOT_ALLOWED":
      return .managerOnly
    case "VOTE_ALREADY_OPEN":
      return .alreadyOpen
    case "VOTE_INVALID_STATUS", "VOTE_NOT_DRAFT", "VOTE_NOT_OPEN", "VALIDATION_ERROR":
      return .invalidStatus
    default:
      break
    }

    switch statusCode {
    case 403:
      return .managerOnly
    case 404:
      return .notFound
    default:
      return .unknown
    }
  }
}
