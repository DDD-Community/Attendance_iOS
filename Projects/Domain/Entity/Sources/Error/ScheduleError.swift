//
//  ScheduleError.swift
//  Presentation
//
//  Created by Wonji Suh  on 1/10/26.
//

import Foundation

public enum ScheduleError: LocalizedError, Equatable {
  case networkError(String)
  case decodingError(String)
  case noData
  case invalidDate
  case unauthorized
  case serverError(Int)
  case unknown(String)

  public var errorDescription: String? {
    switch self {
    case .networkError(let message):
      return "네트워크 오류: \(message)"
    case .decodingError(let message):
      return "데이터 파싱 오류: \(message)"
    case .noData:
      return "스케줄 데이터가 없습니다"
    case .invalidDate:
      return "잘못된 날짜 형식입니다"
    case .unauthorized:
      return "권한이 없습니다"
    case .serverError(let code):
      return "서버 오류 (코드: \(code))"
    case .unknown(let message):
      return "알 수 없는 오류: \(message)"
    }
  }

  public var failureReason: String? {
    switch self {
    case .networkError:
      return "네트워크 연결을 확인해주세요"
    case .decodingError:
      return "서버 응답 데이터가 올바르지 않습니다"
    case .noData:
      return "등록된 스케줄이 없습니다"
    case .invalidDate:
      return "날짜 형식을 확인해주세요"
    case .unauthorized:
      return "로그인이 필요합니다"
    case .serverError:
      return "잠시 후 다시 시도해주세요"
    case .unknown:
      return "예상치 못한 오류가 발생했습니다"
    }
  }

  public var recoverySuggestion: String? {
    switch self {
    case .networkError:
      return "인터넷 연결을 확인하고 다시 시도해주세요"
    case .decodingError:
      return "앱을 다시 시작해보세요"
    case .noData:
      return "새로고침하거나 관리자에게 문의하세요"
    case .invalidDate:
      return "올바른 날짜를 입력해주세요"
    case .unauthorized:
      return "다시 로그인해주세요"
    case .serverError:
      return "잠시 후 다시 시도하거나 고객센터에 문의하세요"
    case .unknown:
      return "문제가 지속되면 고객센터에 문의해주세요"
    }
  }
}

public extension ScheduleError {
  static func from(_ error: Error) -> ScheduleError {
    if let scheduleError = error as? ScheduleError {
      return scheduleError
    }
    return .unknown(error.localizedDescription)
  }
}
