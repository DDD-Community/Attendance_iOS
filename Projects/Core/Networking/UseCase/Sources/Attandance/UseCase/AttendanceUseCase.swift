//
//  AttendanceUseCase.swift
//  UseCase
//
//  Created by Wonji Suh  on 5/10/25.
//

import Model

import ComposableArchitecture
import DiContainer

public struct AttendanceUseCase: AttendanceUseCaseProtocol {
  private let repository: AttendanceRepositoryProtocol
  
  public init(
    repository: AttendanceRepositoryProtocol
  ) {
    self.repository = repository
  }
  
  // MARK: - 출석 현황 카운트 api
  public func attendanceCount(
    startDate: String
  ) async throws -> AttendanceCountDTOModel? {
    return try await repository.attendanceCount(startDate: startDate)
  }
}

extension DependencyContainer {
  var attendanceUseCase: AttendanceRepositoryProtocol? {
    resolve(AttendanceRepositoryProtocol.self)
  }
}


extension AttendanceUseCase: DependencyKey {
  static public var liveValue: AttendanceUseCase = {
    let attendanceRepository = ContainerResgister(\.attendanceUseCase).wrappedValue
    return AttendanceUseCase(repository: attendanceRepository)
  }()
}

public extension DependencyValues {
  var sattendanceUseCase: AttendanceUseCase {
    get { self[AttendanceUseCase.self] }
    set { self[AttendanceUseCase.self] = newValue }
  }
}

public extension RegisterModule {
  
  var attendanceUseCaseModule: () -> Module {
    makeUseCaseWithRepository(
      AttendanceUseCaseProtocol.self,
      repositoryProtocol: AttendanceRepositoryProtocol.self,
      repositoryFallback: DefaultAttendanceRepository(),
      factory: { repo in
        AttendanceUseCase(repository: repo)
      }
    )
  }
  
  var attendanceRepositoryModule: () -> Module {
    makeDependency(AttendanceRepositoryProtocol.self) {
      AttendanceRepository()
    }
  }
  
}
