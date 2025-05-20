//
//  ScheduleUseCase.swift
//  UseCase
//
//  Created by Wonji Suh  on 5/9/25.
//


import Model

import ComposableArchitecture
import DiContainer

public struct ScheduleUseCase: ScheduleUseCaseProtocol {
  private let repository: ScheduleRepositoryProtocol
  
  public init(
    repository: ScheduleRepositoryProtocol
  ) {
    self.repository = repository
  }
  
  // MARK: - 스케줄 조회
  public func getSchedules() async throws -> ScheduleModel? {
    return try await repository.getSchedules()
  }
  
  // MARK: - 스케줄 날짜 필터
  public func filtergetSchedules(
    startDate: String
  ) async throws -> ScheduleModel? {
    return try await repository.filtergetSchedules(startDate: startDate)
  }
}


extension DependencyContainer {
  var scheduleUseCase: ScheduleRepositoryProtocol? {
    resolve(ScheduleRepositoryProtocol.self)
  }
}


extension ScheduleUseCase: DependencyKey {
  static public var liveValue: ScheduleUseCase = {
    let scheduleRepository = ContainerResgister(\.scheduleUseCase).wrappedValue
    return ScheduleUseCase(repository: scheduleRepository)
  }()
}

public extension DependencyValues {
  var scheduleUseCase: ScheduleUseCase {
    get { self[ScheduleUseCase.self] }
    set { self[ScheduleUseCase.self] = newValue }
  }
}

public extension RegisterModule {
  
  var scheduleUseCaseModule: () -> Module {
    makeUseCaseWithRepository(
      ScheduleUseCaseProtocol.self,
      repositoryProtocol: ScheduleRepositoryProtocol.self,
      repositoryFallback: DefaultScheduleRepository(),
      factory: { repo in
        ScheduleUseCase(repository: repo)
      }
    )
  }
  
  var scheduleRepositoryModule: () -> Module {
    makeDependency(ScheduleRepositoryProtocol.self) {
      ScheduleRepository()
    }
  }
  
}
