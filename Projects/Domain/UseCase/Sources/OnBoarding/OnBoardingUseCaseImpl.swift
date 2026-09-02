//
//  OnBoardingUseCaseImpl.swift
//  UseCase
//
//  Created by DDD on 12/30/25.
//

import Dependencies
import DomainInterface
import Entity


public struct OnBoardingUseCaseImpl: OnBoardingInterface {
  @Dependency(\.onBoardingRepository) var repository

  public init() {}


  public func verifyCode(
    code: String
  ) async throws(OnBoardingError) -> Entity.VerifyCodeEntity {
    return try await repository.verifyCode(code: code)
  }

  public func fetchJobs() async throws(OnBoardingError) -> [Entity.SelectJob] {
    return try await repository.fetchJobs()
  }

  public func fetchTeams(
    generationId: Int
  ) async throws(OnBoardingError) -> [SelectTeamEntity] {
    return try await repository.fetchTeams(generationId: generationId)
  }

  public func fetchManaging() async throws(OnBoardingError) -> [SelectManaging] {
    return try await repository.fetchManaging()
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
