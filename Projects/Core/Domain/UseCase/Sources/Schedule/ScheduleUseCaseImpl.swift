//
//  ScheduleUseCaseImpl.swift
//  UseCase
//
//  Created by Wonji Suh  on 7/23/25.
//

import DomainInterface
import DiContainer
import Model
import Repository

import ComposableArchitecture

public struct ScheduleUseCaseImpl: ScheduleInterface {
  private let repository: ScheduleInterface

  public init(
    repository: ScheduleInterface
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
  var scheduleUseCase: ScheduleInterface? {
    resolve(ScheduleInterface.self)
  }
}


extension ScheduleUseCaseImpl: DependencyKey {
  static public var liveValue: ScheduleInterface = {
    let repository = ContainerResgister(\.scheduleUseCase).wrappedValue
    return ScheduleUseCaseImpl(repository: repository)
  }()
}

public extension DependencyValues {
  var scheduleUseCase: ScheduleInterface {
    get { self[ScheduleUseCaseImpl.self] }
    set { self[ScheduleUseCaseImpl.self] = newValue }
  }
}

public extension RegisterModule {

  var scheduleUseCaseImplModule: () -> Module {
    makeUseCaseWithRepository(
      ScheduleInterface.self,
      repositoryProtocol: ScheduleInterface.self,
      repositoryFallback: DefaultScheduleRepositoryImpl(),
      factory: { repo in
        ScheduleUseCaseImpl(repository: repo)
      }
    )
  }

  var scheduleRepositoryImplModule: () -> Module {
    makeDependency(ScheduleInterface.self) {
      ScheduleRepositoryImpl()
    }
  }

}
