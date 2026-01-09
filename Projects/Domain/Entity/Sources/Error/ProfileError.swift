//
//  ProfileError.swift
//  Entity
//
//  Created by Claude on 1/4/26.
//

import Foundation

public enum ProfileError: Error, LocalizedError, Equatable {
  // MARK: - Profile Fetch Related Errors
  case profileNotFound
  case profileAccessDenied
  case profileDataCorrupted


  // MARK: - General Errors
  case unknownError(String)
  case userCancelled
  case missingRequiredField(String)

  public var errorDescription: String? {
    switch self {
    // Profile Fetch Related Errors
    case .profileNotFound:
      return "프로필을 찾을 수 없습니다"
    case .profileAccessDenied:
      return "프로필 접근이 거부되었습니다"
    case .profileDataCorrupted:
      return "프로필 데이터가 손상되었습니다"


    // General Errors
    case .unknownError(let message):
      return "알 수 없는 오류가 발생했습니다: \(message)"
    case .userCancelled:
      return "사용자가 취소했습니다"
    case .missingRequiredField(let field):
      return "\(field)은(는) 필수 입력 항목입니다"
    }
  }

  public var failureReason: String? {
    switch self {
    case .profileNotFound:
      return "프로필 조회 실패"
    case .profileAccessDenied:
      return "프로필 접근 권한 부족"
    default:
      return nil
    }
  }

  public var recoverySuggestion: String? {
    switch self {
    case .profileNotFound:
      return "프로필 정보를 다시 설정하거나 관리자에게 문의해주세요"
    case .profileAccessDenied:
      return "관리자에게 권한 요청을 문의해주세요"
    default:
      return "문제가 지속되면 고객센터에 문의해주세요"
    }
  }
}

// MARK: - Convenience Methods

public extension ProfileError {
  static func from(_ error: Error) -> ProfileError {
    if let profileError = error as? ProfileError {
      return profileError
    }
    return .unknownError(error.localizedDescription)
  }

  /// 프로필 조회 관련 에러인지 확인
  var isFetchError: Bool {
    switch self {
    case .profileNotFound, .profileAccessDenied, .profileDataCorrupted:
      return true
    default:
      return false
    }
  }

  /// 재시도 가능한 에러인지 확인
  var isRetryable: Bool {
    switch self {
    default:
      return false
    }
  }

  /// 사용자 액션이 필요한 에러인지 확인
  var requiresUserAction: Bool {
    switch self {
    case .profileAccessDenied:
      return true
    default:
      return false
    }
  }
}