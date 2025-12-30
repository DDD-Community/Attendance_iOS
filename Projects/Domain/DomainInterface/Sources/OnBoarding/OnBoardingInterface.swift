//
//  OnBoardingInterface.swift
//  DomainInterface
//
//  Created by Wonji Suh  on 12/30/25.
//

import Foundation

import WeaveDI
import Entity


public protocol OnBoardingInterface: Sendable {
  func verifyCode(code: String) async throws -> VerifyCodeEntity
}

public struct OnBoardingRepositoryDependency: DependencyKey {
  public static var liveValue: OnBoardingInterface {
    UnifiedDI.resolve(OnBoardingInterface.self) ?? DefaultOnBoardingRepositoryImpl()
  }

  public static var testValue: OnBoardingInterface {
    UnifiedDI.resolve(OnBoardingInterface.self) ?? DefaultOnBoardingRepositoryImpl()
  }

  public static var previewValue: OnBoardingInterface {
    MockOnBoardingRepository.success()
  }
}

public extension DependencyValues {
  var onBoardingRepository: OnBoardingInterface {
    get { self[OnBoardingRepositoryDependency.self] }
    set { self[OnBoardingRepositoryDependency.self] = newValue }
  }
}

