//
//  FetchAttendancesUseCaseImpl.swift
//  UseCase
//
//  Created by 홍은표 on 1/12/26.
//

import Foundation

import DomainInterface
import Entity

import WeaveDI

public protocol FetchMyAttendancesUseCase: Sendable {
  func execute() async throws -> AttendanceSummaryResponse
}

public struct FetchMyAttendancesUseCaseImpl: FetchMyAttendancesUseCase {
  private let repository: any MyPageRepositoryInterface
  
  public init(repository: any MyPageRepositoryInterface) {
    self.repository = repository
  }
  
  public func execute() async throws -> AttendanceSummaryResponse {
    return try await repository.fetchAttendances()
  }
}

public enum FetchAttendancesUseCaseKey: DependencyKey {
  static public var liveValue: any FetchMyAttendancesUseCase {
    @Dependency(\.myPageRepository) var repository
    return FetchMyAttendancesUseCaseImpl(repository: repository)
  }
}

public extension DependencyValues {
  var fetchMyAttendancesUseCase: any FetchMyAttendancesUseCase {
    get { self[FetchAttendancesUseCaseKey.self] }
    set { self[FetchAttendancesUseCaseKey.self] = newValue }
  }
}
