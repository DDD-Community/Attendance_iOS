//
//  FetchSchedulesUseCase.swift
//  UseCase
//
//  Created by DDD on 1/12/26.
//

import Foundation

import Dependencies

import DomainInterface
import Entity


public protocol FetchMySchedulesUseCase: Sendable {
  func execute() async throws(MyPageError) -> [AttendanceMyScheduleResponse]
}

public struct FetchMySchedulesUseCaseImpl: FetchMySchedulesUseCase {
  private let repository: any MyPageRepositoryInterface
  
  public init(repository: any MyPageRepositoryInterface) {
    self.repository = repository
  }
  
  public func execute() async throws(MyPageError) -> [AttendanceMyScheduleResponse] {
    return try await repository.fetchSchedules()
  }
}

public enum FetchMySchedulesUseCaseKey: DependencyKey {
  static public var liveValue: any FetchMySchedulesUseCase {
    @Dependency(\.myPageRepository) var repository
    return FetchMySchedulesUseCaseImpl(repository: repository)
  }
}

public extension DependencyValues {
  var fetchMySchedulesUseCase: any FetchMySchedulesUseCase {
    get { self[FetchMySchedulesUseCaseKey.self] }
    set { self[FetchMySchedulesUseCaseKey.self] = newValue }
  }
}
