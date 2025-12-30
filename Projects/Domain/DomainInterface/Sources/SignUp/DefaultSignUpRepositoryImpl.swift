//
//  DefaultSignUpRepositoryImpl.swift
//  DomainInterface
//
//  Created by Wonji Suh  on 7/23/25.
//  Moved from Repository module
//

import Foundation
import Model
import Entity

/// SignUp Repository의 기본 구현체 (테스트/프리뷰용)
final public class DefaultSignUpRepositoryImpl: SignUpInterface, @unchecked Sendable {

  // MARK: - Configuration
  public enum Configuration {
    case success
    case failure
    case invalidInviteCode
    case expiredInviteCode
    case networkError
    case serverError
    case customDelay(TimeInterval)

    var shouldSucceed: Bool {
      switch self {
      case .success, .customDelay:
        return true
      case .failure, .invalidInviteCode, .expiredInviteCode, .networkError, .serverError:
        return false
      }
    }

    var delay: TimeInterval {
      switch self {
      case .customDelay(let delay):
        return delay
      default:
        return 1.0 // 실제 네트워크 지연 시뮬레이션
      }
    }

    var signUpError: SignUpError? {
      switch self {
      case .success, .customDelay:
        return nil
      case .failure:
        return .accountCreationFailed
      case .invalidInviteCode:
        return .invalidInviteCode
      case .expiredInviteCode:
        return .expiredInviteCode
      case .networkError:
        return .networkError
      case .serverError:
        return .serverError("서버 내부 오류")
      }
    }
  }

  // MARK: - Properties
  private var configuration: Configuration = .success
  private var registerCallCount = 0
  private var validateCallCount = 0
  private var checkEmailCallCount = 0
  private var lastCall: Date?

  // MARK: - Initialization

  public init(configuration: Configuration = .success) {
    self.configuration = configuration
  }

  // MARK: - Configuration Methods

  public func setConfiguration(_ configuration: Configuration) {
    self.configuration = configuration
    registerCallCount = 0
    validateCallCount = 0
    checkEmailCallCount = 0
    lastCall = nil
  }

  public func getRegisterCallCount() -> Int { registerCallCount }
  public func getValidateCallCount() -> Int { validateCallCount }
  public func getCheckEmailCallCount() -> Int { checkEmailCallCount }
  public func getLastCall() -> Date? { lastCall }

  public func reset() {
    configuration = .success
    registerCallCount = 0
    validateCallCount = 0
    checkEmailCallCount = 0
    lastCall = nil
  }

  // MARK: - SignUpInterface Implementation

  public func registerAccount(
    email: String,
    password: String
  ) async throws -> SignUpModel? {
    // Track call
    registerCallCount += 1
    lastCall = Date()

    // Apply delay
    if configuration.delay > 0 {
      try await Task.sleep(for: .seconds(configuration.delay))
    }

    // 입력 값 검증
    guard !email.isEmpty else {
      throw SignUpError.missingRequiredField("이메일")
    }

    guard !password.isEmpty else {
      throw SignUpError.missingRequiredField("비밀번호")
    }

    // 특정 패턴 검사 (간소화)
    if email == "invalid@" || !email.contains("@") {
      throw SignUpError.missingRequiredField("유효한 이메일")
    }

    if email == "duplicate@example.com" {
      throw SignUpError.accountAlreadyExists
    }

    // 비밀번호 검증
    if password.count < 8 {
      throw SignUpError.missingRequiredField("8자 이상의 비밀번호")
    }

    if password == "weak" || password == "123456" {
      throw SignUpError.missingRequiredField("강력한 비밀번호")
    }

    // Configuration 기반 응답 처리
    if !configuration.shouldSucceed, let error = configuration.signUpError {
      throw error
    }

    // Success case
    let mockUser = SignUPUser(
      username: email.components(separatedBy: "@").first ?? "User",
      email: email
    )

    let mockResponse = SignUpResponseModel(
      accessToken: "mock_access_token_\(UUID().uuidString)",
      refreshToken: "mock_refresh_token_\(UUID().uuidString)",
      user: mockUser
    )

    return BaseResponseDTO(
      code: 200,
      message: "회원가입이 성공적으로 완료되었습니다",
      data: mockResponse
    )
  }

  public func validateInviteCode(
    inviteCode: String
  ) async throws -> InviteCodeModel? {
    // Track call
    validateCallCount += 1
    lastCall = Date()

    // Apply delay
    if configuration.delay > 0 {
      try await Task.sleep(for: .seconds(configuration.delay))
    }

    // 입력 값 검증
    guard !inviteCode.isEmpty else {
      throw SignUpError.missingRequiredField("초대 코드")
    }

    // 특정 코드별 처리
    switch inviteCode.lowercased() {
    case "invalid", "wrong", "used", "format", "unauthorized", "forbidden", "team", "revoked":
      throw SignUpError.invalidInviteCode
    case "expired":
      throw SignUpError.expiredInviteCode
    case "error":
      throw SignUpError.networkError
    default:
      break
    }

    // Configuration 기반 응답 처리
    if !configuration.shouldSucceed, let error = configuration.signUpError {
      throw error
    }

    // Success case
    let mockResponse = InviteCodeResponseModel(
      valid: true,
      inviteCodeID: inviteCode,
      inviteType: "TEAM_INVITE",
      oneTimeUse: true,
      errorMessage: nil
    )

    return BaseResponseDTO(
      code: 200,
      message: "유효한 초대 코드입니다",
      data: mockResponse
    )
  }

  public func checkEmail(
    email: String
  ) async throws -> CheckEmailModel? {
    // Track call
    checkEmailCallCount += 1
    lastCall = Date()

    // Apply delay
    if configuration.delay > 0 {
      try await Task.sleep(for: .seconds(configuration.delay))
    }

    // 입력 값 검증
    guard !email.isEmpty else {
      throw SignUpError.missingRequiredField("이메일")
    }

    // 이메일 형식 검증
    if !email.contains("@") || !email.contains(".") {
      throw SignUpError.missingRequiredField("유효한 이메일")
    }

    // 특정 이메일별 처리
    let isUsed = email == "duplicate@example.com" ||
                 email == "used@example.com" ||
                 email == "admin@example.com"

    // Configuration 기반 응답 처리
    if !configuration.shouldSucceed, let error = configuration.signUpError {
      throw error
    }

    // Success case
    let mockResponse = CheckEmailResponseModel(emailUsed: isUsed)

    return BaseResponseDTO(
      code: 200,
      message: isUsed ? "이미 사용 중인 이메일입니다" : "사용 가능한 이메일입니다",
      data: mockResponse
    )
  }
}

// MARK: - Convenience Static Methods

public extension DefaultSignUpRepositoryImpl {

  /// Creates a pre-configured instance for success scenario
  static func success() -> DefaultSignUpRepositoryImpl {
    return DefaultSignUpRepositoryImpl(configuration: .success)
  }

  /// Creates a pre-configured instance for failure scenario
  static func failure() -> DefaultSignUpRepositoryImpl {
    return DefaultSignUpRepositoryImpl(configuration: .failure)
  }

  /// Creates a pre-configured instance for invalid invite code scenario
  static func invalidInviteCode() -> DefaultSignUpRepositoryImpl {
    return DefaultSignUpRepositoryImpl(configuration: .invalidInviteCode)
  }

  /// Creates a pre-configured instance for expired invite code scenario
  static func expiredInviteCode() -> DefaultSignUpRepositoryImpl {
    return DefaultSignUpRepositoryImpl(configuration: .expiredInviteCode)
  }

  /// Creates a pre-configured instance for network error scenario
  static func networkError() -> DefaultSignUpRepositoryImpl {
    return DefaultSignUpRepositoryImpl(configuration: .networkError)
  }

  /// Creates a pre-configured instance with custom delay
  static func withDelay(_ delay: TimeInterval) -> DefaultSignUpRepositoryImpl {
    return DefaultSignUpRepositoryImpl(configuration: .customDelay(delay))
  }
}