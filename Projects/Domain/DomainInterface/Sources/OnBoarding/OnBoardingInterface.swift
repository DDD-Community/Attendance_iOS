//
//  OnBoardingInterface.swift
//  DomainInterface
//
//  Created by DDD on 12/30/25.
//

import Foundation

import Dependencies

import Entity


public protocol OnBoardingInterface: Sendable {
  func verifyCode(code: String) async throws -> VerifyCodeEntity
  func fetchJobs() async throws -> [SelectJob]
  func fetchTeams(generationId: Int) async throws -> [SelectTeamEntity]
  func fetchManaging() async throws -> [SelectManaging]
}

public enum OnBoardingRepositoryDependency: TestDependencyKey {

  public static var testValue: OnBoardingInterface {
    DefaultOnBoardingRepositoryImpl()
  }

  public static var previewValue: OnBoardingInterface = testValue
}

public extension DependencyValues {
  var onBoardingRepository: OnBoardingInterface {
    get { self[OnBoardingRepositoryDependency.self] }
    set { self[OnBoardingRepositoryDependency.self] = newValue }
  }
}

