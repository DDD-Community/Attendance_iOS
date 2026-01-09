//
//  EditProfileError.swift
//  Entity
//
//  Created by Claude on 1/6/26.
//

import Foundation

public enum EditProfileError: Error, LocalizedError, Equatable {
  // MARK: - Profile Field Validation Errors
  case invalidField(String)
  case fieldTooShort(String)
  case fieldTooLong(String)

  // MARK: - Team Related Errors
  case invalidTeam
  case teamNotSelected
  case teamNotAvailable

  // MARK: - Role Related Errors
  case invalidRole
  case roleNotSelected
  case roleNotAvailable

  // MARK: - Generation Related Errors
  case invalidGeneration
  case generationNotFound

  // MARK: - Profile State Errors
  case profileNotFound
  case profileUpdateFailed
  case profileLocked

  // MARK: - Network & Server Errors
  case networkError
  case serverError(String)

  // MARK: - General Errors
  case unknownError(String)
  case userCancelled
  case missingRequiredField(String)

  public var errorDescription: String? {
    switch self {
    // Profile Field Validation Errors
    case .invalidField(let field):
      return "\(field)이(가) 올바르지 않습니다"
    case .fieldTooShort(let field):
      return "\(field)이(가) 너무 짧습니다"
    case .fieldTooLong(let field):
      return "\(field)이(가) 너무 깁니다"

    // Team Related Errors
    case .invalidTeam:
      return "유효하지 않은 팀입니다"
    case .teamNotSelected:
      return "팀을 선택해주세요"
    case .teamNotAvailable:
      return "선택한 팀을 사용할 수 없습니다"

    // Role Related Errors
    case .invalidRole:
      return "유효하지 않은 역할입니다"
    case .roleNotSelected:
      return "역할을 선택해주세요"
    case .roleNotAvailable:
      return "선택한 역할을 사용할 수 없습니다"

    // Generation Related Errors
    case .invalidGeneration:
      return "유효하지 않은 기수입니다"
    case .generationNotFound:
      return "해당 기수를 찾을 수 없습니다"

    // Profile State Errors
    case .profileNotFound:
      return "프로필을 찾을 수 없습니다"
    case .profileUpdateFailed:
      return "프로필 업데이트에 실패했습니다"
    case .profileLocked:
      return "프로필이 잠겨있어 수정할 수 없습니다"

    // Network & Server Errors
    case .networkError:
      return "네트워크 연결을 확인해주세요"
    case .serverError(let message):
      return "서버 오류: \(message)"

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
    case .invalidField:
      return "필드 검증 실패"
    case .invalidTeam:
      return "팀 검증 실패"
    case .teamNotSelected:
      return "팀 선택 실패"
    case .invalidRole:
      return "역할 검증 실패"
    case .profileNotFound:
      return "프로필 조회 실패"
    case .profileUpdateFailed:
      return "프로필 업데이트 실패"
    case .networkError:
      return "네트워크 연결 실패"
    case .serverError:
      return "서버 처리 실패"
    default:
      return nil
    }
  }

  public var recoverySuggestion: String? {
    switch self {
    case .invalidField:
      return "올바른 값을 입력해주세요"
    case .invalidTeam:
      return "유효한 팀을 선택해주세요"
    case .teamNotSelected:
      return "목록에서 팀을 선택해주세요"
    case .teamNotAvailable:
      return "다른 팀을 선택하거나 관리자에게 문의해주세요"
    case .invalidRole:
      return "유효한 역할을 선택해주세요"
    case .profileNotFound:
      return "앱을 재시작하거나 로그인을 다시 해주세요"
    case .profileUpdateFailed:
      return "잠시 후 다시 시도해주세요"
    case .networkError:
      return "인터넷 연결을 확인하고 다시 시도해주세요"
    default:
      return "문제가 지속되면 고객센터에 문의해주세요"
    }
  }
}

// MARK: - Convenience Methods

public extension EditProfileError {
  static func from(_ error: Error) -> EditProfileError {
    if let editProfileError = error as? EditProfileError {
      return editProfileError
    }
    return .unknownError(error.localizedDescription)
  }

  /// 필드 관련 에러인지 확인
  var isFieldError: Bool {
    switch self {
    case .invalidField, .fieldTooShort, .fieldTooLong, .missingRequiredField:
      return true
    default:
      return false
    }
  }

  /// 팀 관련 에러인지 확인
  var isTeamError: Bool {
    switch self {
    case .invalidTeam, .teamNotSelected, .teamNotAvailable:
      return true
    default:
      return false
    }
  }

  /// 역할 관련 에러인지 확인
  var isRoleError: Bool {
    switch self {
    case .invalidRole, .roleNotSelected, .roleNotAvailable:
      return true
    default:
      return false
    }
  }

  /// 네트워크 관련 에러인지 확인
  var isNetworkError: Bool {
    switch self {
    case .networkError:
      return true
    default:
      return false
    }
  }

  /// 재시도 가능한 에러인지 확인
  var isRetryable: Bool {
    switch self {
    case .networkError, .serverError, .profileUpdateFailed:
      return true
    default:
      return false
    }
  }
}