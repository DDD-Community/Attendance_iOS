//
//  OnBoardingUseCaseImpl.swift
//  UseCase
//
//  Created by Wonji Suh  on 12/30/25.
//

import DomainInterface
import Entity

import WeaveDI

public struct OnBoardingUseCaseImpl: OnBoardingInterface {
  @Dependency(\.onBoardingRepository) var repository

  public init() {}


  public func verifyCode(
    code: String
  ) async throws -> Entity.VerifyCodeEntity {
    return try await repository.verifyCode(code: code)
  }
}


extension OnBoardingUseCaseImpl : DependencyKey {
  static public var liveValue = OnBoardingUseCaseImpl()
  static public var testValue = OnBoardingUseCaseImpl()
  static public var previewValue = OnBoardingUseCaseImpl()
}

public extension DependencyValues {
   var onBoardingUseCase: OnBoardingUseCaseImpl {
    get { self[OnBoardingUseCaseImpl.self] }
    set { self[OnBoardingUseCaseImpl.self] = newValue }
  }
}
