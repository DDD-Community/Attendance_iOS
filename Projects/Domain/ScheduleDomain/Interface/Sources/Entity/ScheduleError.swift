//
//  ScheduleError.swift
//  Presentation
//
//  Created by DDD on 1/10/26.
//

import Foundation

/// 스케줄 도메인의 실패만 담는다.
/// 네트워크·디코딩·HTTP 상태 같은 전송 관심사는 DDDNetwork 의 `DDDNetworkError` 가 소유하고,
/// Repository 가 서버 응답 코드로 도메인 케이스를 고르지 못하면 `.unknown` 으로 흡수한다.
public enum ScheduleError: LocalizedError, Equatable {
  case invalidDate
  case loadFailed
  case cacheFailed
  case unknown

  public var errorDescription: String? {
    switch self {
    case .invalidDate:
      return "잘못된 날짜 형식입니다"
    case .loadFailed:
      return "일정을 불러오지 못했습니다"
    case .cacheFailed:
      return "일정 저장소를 처리하지 못했습니다"
    case .unknown:
      return "알 수 없는 오류가 발생했습니다"
    }
  }

  public var failureReason: String? {
    switch self {
    case .invalidDate:
      return "날짜 형식을 확인해주세요"
    case .loadFailed:
      return "일정 조회에 실패했습니다"
    case .cacheFailed:
      return "일정 저장에 실패했습니다"
    case .unknown:
      return "예상치 못한 오류가 발생했습니다"
    }
  }

  public var recoverySuggestion: String? {
    switch self {
    case .invalidDate:
      return "올바른 날짜를 입력해주세요"
    case .loadFailed, .cacheFailed:
      return "잠시 후 다시 시도해주세요"
    case .unknown:
      return "문제가 지속되면 고객센터에 문의해주세요"
    }
  }
}

public extension ScheduleError {
  /// 이미 도메인 에러인 값을 그대로 통과시킨다.
  /// Repository 가 typed throws 로 던지므로 여기서는 캐스팅만 하고,
  /// 그 밖의 에러는 전송 실패로 보고 `.unknown` 으로 흡수한다.
  static func from(_ error: any Error) -> ScheduleError {
    (error as? ScheduleError) ?? .unknown
  }

  /// 서버가 내려준 에러 코드를 도메인 케이스로 옮긴다. VoteError 와 같은 계약이다.
  /// 코드로 못 가리면 HTTP status 로 한 번 더 시도하고, 그래도 없으면 `.unknown` 이다.
  static func from(
    statusCode: Int,
    code _: String? = nil,
    message _: String? = nil
  ) -> ScheduleError {
    switch statusCode {
    case 400:
      return .invalidDate
    default:
      return .unknown
    }
  }
}
