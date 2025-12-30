//
//  DefaultOnBoardingRepositoryImpl.swift
//  DomainInterface
//
//  Created by Wonji Suh  on 12/30/25.
//

import Foundation
import Entity

// MARK: - OnBoarding Errors

public enum OnBoardingError: Error, LocalizedError {
  case invalidCode
  case verifyFailed
  case networkError
  case unknownError

  public var errorDescription: String? {
    switch self {
    case .invalidCode:
      return "Invalid verification code"
    case .verifyFailed:
      return "Verification failed"
    case .networkError:
      return "Network connection error"
    case .unknownError:
      return "Unknown error occurred"
    }
  }
}

public final class DefaultOnBoardingRepositoryImpl: OnBoardingInterface, @unchecked Sendable {

  // MARK: - Configuration
  public enum Configuration {
    case success
    case failure
    case invalidCode
    case networkError
    case memberRole
    case managerRole
    case customDelay(TimeInterval)

    var shouldSucceed: Bool {
      switch self {
      case .success, .memberRole, .managerRole, .customDelay:
        return true
      case .failure, .invalidCode, .networkError:
        return false
      }
    }

    var delay: TimeInterval {
      switch self {
      case .customDelay(let delay):
        return delay
      default:
        return 0.5 // 실제 네트워크 지연 시뮬레이션
      }
    }

    var staffType: Staff {
      switch self {
      case .managerRole:
        return .manger
      default:
        return .member
      }
    }

    var mockGenerationID: Int {
      switch self {
      case .managerRole:
        return 2024
      default:
        return 2025
      }
    }

    var error: OnBoardingError? {
      switch self {
      case .success, .memberRole, .managerRole, .customDelay:
        return nil
      case .failure:
        return .verifyFailed
      case .invalidCode:
        return .invalidCode
      case .networkError:
        return .networkError
      }
    }
  }

  // MARK: - Properties
  private var configuration: Configuration = .success
  private var verifyCallCount = 0
  private var lastVerifyCall: Date?

  // MARK: - Initialization

  public init(configuration: Configuration = .success) {
    self.configuration = configuration
  }

  // MARK: - Configuration Methods

  public func setConfiguration(_ configuration: Configuration) {
    self.configuration = configuration
    verifyCallCount = 0
    lastVerifyCall = nil
  }

  public func getVerifyCallCount() -> Int {
    return verifyCallCount
  }

  public func getLastVerifyCall() -> Date? {
    return lastVerifyCall
  }

  public func reset() {
    configuration = .success
    verifyCallCount = 0
    lastVerifyCall = nil
  }

  // MARK: - OnBoardingInterface Implementation

  public func verifyCode(code: String) async throws -> VerifyCodeEntity {
    // Track call
    verifyCallCount += 1
    lastVerifyCall = Date()

    // Apply delay
    if configuration.delay > 0 {
      try await Task.sleep(for: .seconds(configuration.delay))
    }

    // 코드 유효성 검사 (기본적인 검사)
    guard !code.isEmpty, code.count >= 4 else {
      throw OnBoardingError.invalidCode
    }

    // Configuration 기반 응답 처리
    if !configuration.shouldSucceed, let error = configuration.error {
      throw error
    }

    // 특정 코드에 따른 응답 분기 처리
    switch code {
    case "1234", "test", "member":
      return VerifyCodeEntity(
        generationID: 2025,
        type: .member
      )

    case "5678", "admin", "manager":
      return VerifyCodeEntity(
        generationID: 2024,
        type: .manger
      )

    case "error", "fail":
      throw OnBoardingError.verifyFailed

    case "network":
      throw OnBoardingError.networkError

    case "invalid", "wrong":
      throw OnBoardingError.invalidCode

    default:
      // Configuration에 따른 기본 응답
      return VerifyCodeEntity(
        generationID: configuration.mockGenerationID,
        type: configuration.staffType
      )
    }
  }
}

// MARK: - Convenience Static Methods

public extension DefaultOnBoardingRepositoryImpl {

  /// Creates a pre-configured instance for success scenario with member role
  static func success() -> DefaultOnBoardingRepositoryImpl {
    return DefaultOnBoardingRepositoryImpl(configuration: .success)
  }

  /// Creates a pre-configured instance for failure scenario
  static func failure() -> DefaultOnBoardingRepositoryImpl {
    return DefaultOnBoardingRepositoryImpl(configuration: .failure)
  }

  /// Creates a pre-configured instance for invalid code scenario
  static func invalidCode() -> DefaultOnBoardingRepositoryImpl {
    return DefaultOnBoardingRepositoryImpl(configuration: .invalidCode)
  }

  /// Creates a pre-configured instance for member role scenario
  static func memberRole() -> DefaultOnBoardingRepositoryImpl {
    return DefaultOnBoardingRepositoryImpl(configuration: .memberRole)
  }

  /// Creates a pre-configured instance for manager role scenario
  static func managerRole() -> DefaultOnBoardingRepositoryImpl {
    return DefaultOnBoardingRepositoryImpl(configuration: .managerRole)
  }

  /// Creates a pre-configured instance for network error scenario
  static func networkError() -> DefaultOnBoardingRepositoryImpl {
    return DefaultOnBoardingRepositoryImpl(configuration: .networkError)
  }

  /// Creates a pre-configured instance with custom delay
  static func withDelay(_ delay: TimeInterval) -> DefaultOnBoardingRepositoryImpl {
    return DefaultOnBoardingRepositoryImpl(configuration: .customDelay(delay))
  }
}
