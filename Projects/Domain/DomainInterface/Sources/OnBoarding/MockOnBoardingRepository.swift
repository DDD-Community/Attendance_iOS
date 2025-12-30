//
//  MockOnBoardingRepository.swift
//  DomainInterface
//
//  Created by Wonji Suh  on 12/30/25.
//

import Foundation
import Entity

public actor MockOnBoardingRepository: OnBoardingInterface {

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
        return 0.1
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

  // MARK: - State
  private var configuration: Configuration = .success
  private var verifyCallCount = 0
  private var lastVerifyCall: Date?

  // MARK: - Public Configuration Methods

  public init(configuration: Configuration = .success) {
    self.configuration = configuration
  }

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

    // Handle failure scenarios
    if !configuration.shouldSucceed, let error = configuration.error {
      throw error
    }

    // Return success payload
    return VerifyCodeEntity(
      generationID: configuration.mockGenerationID,
      type: configuration.staffType
    )
  }
}

// MARK: - Convenience Static Methods

public extension MockOnBoardingRepository {

  /// Creates a pre-configured actor for success scenario with member role
  static func success() -> MockOnBoardingRepository {
    return MockOnBoardingRepository(configuration: .success)
  }

  /// Creates a pre-configured actor for failure scenario
  static func failure() -> MockOnBoardingRepository {
    return MockOnBoardingRepository(configuration: .failure)
  }

  /// Creates a pre-configured actor for invalid code scenario
  static func invalidCode() -> MockOnBoardingRepository {
    return MockOnBoardingRepository(configuration: .invalidCode)
  }

  /// Creates a pre-configured actor for member role scenario
  static func memberRole() -> MockOnBoardingRepository {
    return MockOnBoardingRepository(configuration: .memberRole)
  }

  /// Creates a pre-configured actor for manager role scenario
  static func managerRole() -> MockOnBoardingRepository {
    return MockOnBoardingRepository(configuration: .managerRole)
  }

  /// Creates a pre-configured actor for network error scenario
  static func networkError() -> MockOnBoardingRepository {
    return MockOnBoardingRepository(configuration: .networkError)
  }

  /// Creates a pre-configured actor with custom delay
  static func withDelay(_ delay: TimeInterval) -> MockOnBoardingRepository {
    return MockOnBoardingRepository(configuration: .customDelay(delay))
  }
}

