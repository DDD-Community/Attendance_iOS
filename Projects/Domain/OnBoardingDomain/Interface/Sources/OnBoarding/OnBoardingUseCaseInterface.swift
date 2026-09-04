//
//  OnBoardingUseCaseInterface.swift
//  OnBoardingDomainInterface
//
//  Created by DDD on 9/3/26.
//

import Dependencies

public protocol OnBoardingUseCaseInterface: Sendable {
  func verifyCode(code: String) async throws(OnBoardingError) -> VerifyCodeEntity
  func fetchJobs() async throws(OnBoardingError) -> [SelectJob]
  func fetchTeams(generationId: Int) async throws(OnBoardingError) -> [SelectTeamEntity]
  func fetchManaging() async throws(OnBoardingError) -> [SelectManaging]
}

extension MockOnBoardingRepository: OnBoardingUseCaseInterface {}

public enum OnBoardingUseCaseDependency: TestDependencyKey {
  public static let testValue: any OnBoardingUseCaseInterface = MockOnBoardingRepository()
  public static let previewValue: any OnBoardingUseCaseInterface = testValue
}

public extension DependencyValues {
  var onBoardingUseCase: any OnBoardingUseCaseInterface {
    get { self[OnBoardingUseCaseDependency.self] }
    set { self[OnBoardingUseCaseDependency.self] = newValue }
  }
}
