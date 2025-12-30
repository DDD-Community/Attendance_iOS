//
//  SignUpError.swift
//  Entity
//
//  Created by Wonji Suh  on 12/30/25.
//

import Foundation

public enum SignUpError: Error, LocalizedError, Equatable {
  // MARK: - Email Related Errors
  case invalidEmail
  case duplicateEmail
  case emailNotVerified
  case emailBlocked

  // MARK: - Password Related Errors
  case weakPassword
  case passwordMismatch
  case passwordTooShort
  case passwordTooLong
  case passwordMissingRequirements

  // MARK: - Invite Code Related Errors
  case invalidInviteCode
  case expiredInviteCode

  // MARK: - Account Related Errors
  case accountAlreadyExists
  case accountCreationFailed
  case accountSuspended
  case accountNotActivated

  // MARK: - Validation Errors
  case invalidName
  case nameTooShort
  case nameTooLong
  case invalidPhoneNumber
  case phoneNumberAlreadyExists

  // MARK: - Network & Server Errors
  case networkError
  case serverError(String)
  case timeout
  case serviceUnavailable

  // MARK: - General Errors
  case unknownError(String)
  case userCancelled
  case missingRequiredField(String)

  public var errorDescription: String? {
    switch self {
    // Email Related Errors
    case .invalidEmail:
      return "유효하지 않은 이메일 형식입니다"
    case .duplicateEmail:
      return "이미 사용 중인 이메일입니다"
    case .emailNotVerified:
      return "이메일 인증이 필요합니다"
    case .emailBlocked:
      return "차단된 이메일입니다"

    // Password Related Errors
    case .weakPassword:
      return "더 강력한 비밀번호를 설정해주세요"
    case .passwordMismatch:
      return "비밀번호가 일치하지 않습니다"
    case .passwordTooShort:
      return "비밀번호는 최소 8자 이상이어야 합니다"
    case .passwordTooLong:
      return "비밀번호가 너무 깁니다"
    case .passwordMissingRequirements:
      return "비밀번호는 영문, 숫자, 특수문자를 포함해야 합니다"

    // Invite Code Related Errors
    case .invalidInviteCode:
      return "초대 코드가 잘못 되었습니다"
    case .expiredInviteCode:
      return "만료된 초대 코드입니다"

    // Account Related Errors
    case .accountAlreadyExists:
      return "이미 존재하는 계정입니다"
    case .accountCreationFailed:
      return "계정 생성에 실패했습니다"
    case .accountSuspended:
      return "정지된 계정입니다"
    case .accountNotActivated:
      return "활성화되지 않은 계정입니다"

    // Validation Errors
    case .invalidName:
      return "유효하지 않은 이름입니다"
    case .nameTooShort:
      return "이름이 너무 짧습니다"
    case .nameTooLong:
      return "이름이 너무 깁니다"
    case .invalidPhoneNumber:
      return "유효하지 않은 전화번호입니다"
    case .phoneNumberAlreadyExists:
      return "이미 등록된 전화번호입니다"

    // Network & Server Errors
    case .networkError:
      return "네트워크 연결을 확인해주세요"
    case .serverError(let message):
      return "서버 오류: \(message)"
    case .timeout:
      return "요청 시간이 초과되었습니다"
    case .serviceUnavailable:
      return "서비스를 일시적으로 이용할 수 없습니다"

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
    case .invalidEmail:
      return "이메일 형식 검증 실패"
    case .duplicateEmail:
      return "이메일 중복 검사 실패"
    case .weakPassword:
      return "비밀번호 강도 검증 실패"
    case .invalidInviteCode:
      return "초대 코드 검증 실패"
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
    case .invalidEmail:
      return "올바른 이메일 주소를 입력해주세요 (예: user@example.com)"
    case .duplicateEmail:
      return "다른 이메일 주소를 사용하거나 로그인을 시도해보세요"
    case .weakPassword:
      return "영문, 숫자, 특수문자를 조합하여 8자 이상 입력해주세요"
    case .invalidInviteCode:
      return "초대 코드를 다시 확인하거나 관리자에게 문의해주세요"
    case .networkError:
      return "인터넷 연결을 확인하고 다시 시도해주세요"
    case .timeout:
      return "잠시 후 다시 시도해주세요"
    default:
      return "문제가 지속되면 고객센터에 문의해주세요"
    }
  }
}

// MARK: - Convenience Methods

public extension SignUpError {

  /// 이메일 관련 에러인지 확인
  var isEmailError: Bool {
    switch self {
    case .invalidEmail, .duplicateEmail, .emailNotVerified, .emailBlocked:
      return true
    default:
      return false
    }
  }

  /// 비밀번호 관련 에러인지 확인
  var isPasswordError: Bool {
    switch self {
    case .weakPassword, .passwordMismatch, .passwordTooShort, .passwordTooLong, .passwordMissingRequirements:
      return true
    default:
      return false
    }
  }

  /// 초대 코드 관련 에러인지 확인
  var isInviteCodeError: Bool {
    switch self {
    case .invalidInviteCode, .expiredInviteCode:
      return true
    default:
      return false
    }
  }

  /// 네트워크 관련 에러인지 확인
  var isNetworkError: Bool {
    switch self {
    case .networkError, .timeout, .serviceUnavailable:
      return true
    default:
      return false
    }
  }

  /// 재시도 가능한 에러인지 확인
  var isRetryable: Bool {
    switch self {
    case .networkError, .timeout, .serviceUnavailable, .serverError:
      return true
    default:
      return false
    }
  }
}