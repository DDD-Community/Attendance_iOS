//
//  MockSignUpRepository.swift
//  DomainInterface
//
//  Created by Wonji Suh  on 12/30/25.
//

import Foundation
import Model
import Entity

public actor MockSignUpRepository: SignUpInterface {

  // MARK: - Configuration
  public enum Configuration {
    case success
    case failure
    case invalidInviteCode
    case expiredInviteCode
    case networkError
    case serverError
    case emailCheckedValid
    case emailCheckedUsed
    case customDelay(TimeInterval)

    var shouldSucceed: Bool {
      switch self {
      case .success, .emailCheckedValid, .emailCheckedUsed, .customDelay:
        return true
      case .failure, .invalidInviteCode, .expiredInviteCode,
           .networkError, .serverError:
        return false
      }
    }

    var delay: TimeInterval {
      switch self {
      case .customDelay(let delay):
        return delay
      default:
        return 0.1 // Fast for testing
      }
    }

    var isEmailUsed: Bool {
      switch self {
      case .emailCheckedUsed:
        return true
      default:
        return false
      }
    }

    var signUpError: SignUpError? {
      switch self {
      case .success, .emailCheckedValid, .emailCheckedUsed, .customDelay:
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
        return .serverError("Mock 서버 오류")
      }
    }
  }

  // MARK: - State
  private var configuration: Configuration = .success
  private var registerCallCount = 0
  private var validateCallCount = 0
  private var checkEmailCallCount = 0
  private var lastCall: Date?

  // MARK: - Public Configuration Methods

  public init(configuration: Configuration = .success) {
    self.configuration = configuration
  }

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

    // Handle failure scenarios
    if !configuration.shouldSucceed, let error = configuration.signUpError {
      throw error
    }

    // Success case
    let mockUser = SignUPUser(
      username: createMockUsername(from: email),
      email: email
    )

    let mockResponse = SignUpResponseModel(
      accessToken: createMockAccessToken(),
      refreshToken: createMockRefreshToken(),
      user: mockUser
    )

    return BaseResponseDTO(
      code: 200,
      message: "Mock 회원가입 성공",
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

    // Handle failure scenarios
    if !configuration.shouldSucceed, let error = configuration.signUpError {
      throw error
    }

    // Success case
    let mockResponse = InviteCodeResponseModel(
      valid: true,
      inviteCodeID: inviteCode,
      inviteType: createMockInviteType(),
      oneTimeUse: true,
      errorMessage: nil
    )

    return BaseResponseDTO(
      code: 200,
      message: "Mock 초대 코드 검증 성공",
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

    // Handle failure scenarios
    if !configuration.shouldSucceed, let error = configuration.signUpError {
      throw error
    }

    // Success case
    let mockResponse = CheckEmailResponseModel(
      emailUsed: configuration.isEmailUsed
    )

    return BaseResponseDTO(
      code: 200,
      message: configuration.isEmailUsed ? "Mock 이메일 이미 사용됨" : "Mock 이메일 사용 가능",
      data: mockResponse
    )
  }

  // MARK: - Private Helper Methods

  private func createMockUsername(from email: String) -> String {
    let prefix = email.components(separatedBy: "@").first ?? "MockUser"
    return "\(prefix)_\(UUID().uuidString.prefix(4))"
  }

  private func createMockAccessToken() -> String {
    return "mock_access_\(UUID().uuidString.prefix(16))"
  }

  private func createMockRefreshToken() -> String {
    return "mock_refresh_\(UUID().uuidString.prefix(16))"
  }

  private func createMockInviteType() -> String {
    let types = ["TEAM_INVITE", "PROJECT_INVITE", "ORGANIZATION_INVITE"]
    return types.randomElement() ?? "TEAM_INVITE"
  }
}

// MARK: - Convenience Static Methods

public extension MockSignUpRepository {

  /// Creates a pre-configured actor for success scenario
  static func success() -> MockSignUpRepository {
    return MockSignUpRepository(configuration: .success)
  }

  /// Creates a pre-configured actor for failure scenario
  static func failure() -> MockSignUpRepository {
    return MockSignUpRepository(configuration: .failure)
  }

  /// Creates a pre-configured actor for invalid invite code scenario
  static func invalidInviteCode() -> MockSignUpRepository {
    return MockSignUpRepository(configuration: .invalidInviteCode)
  }

  /// Creates a pre-configured actor for expired invite code scenario
  static func expiredInviteCode() -> MockSignUpRepository {
    return MockSignUpRepository(configuration: .expiredInviteCode)
  }

  /// Creates a pre-configured actor for email check with valid result
  static func emailValid() -> MockSignUpRepository {
    return MockSignUpRepository(configuration: .emailCheckedValid)
  }

  /// Creates a pre-configured actor for email check with used result
  static func emailUsed() -> MockSignUpRepository {
    return MockSignUpRepository(configuration: .emailCheckedUsed)
  }

  /// Creates a pre-configured actor for network error scenario
  static func networkError() -> MockSignUpRepository {
    return MockSignUpRepository(configuration: .networkError)
  }

  /// Creates a pre-configured actor for server error scenario
  static func serverError() -> MockSignUpRepository {
    return MockSignUpRepository(configuration: .serverError)
  }

  /// Creates a pre-configured actor with custom delay
  static func withDelay(_ delay: TimeInterval) -> MockSignUpRepository {
    return MockSignUpRepository(configuration: .customDelay(delay))
  }
}
