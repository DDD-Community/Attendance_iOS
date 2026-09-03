//
//  MyPageUseCaseImpl.swift
//  UseCase
//

import DomainInterface
import Entity
import Dependencies

public protocol MyPageUseCaseInterface: Sendable {
  func fetchAttendances() async throws(MyPageError) -> AttendanceSummaryResponse
  func fetchSchedules() async throws(MyPageError) -> [AttendanceMyScheduleResponse]
}

public struct MyPageUseCaseImpl: MyPageUseCaseInterface {
  private let repository: any MyPageInterface

  public init(repository: any MyPageInterface) {
    self.repository = repository
  }

  public func fetchAttendances() async throws(MyPageError) -> AttendanceSummaryResponse {
    try await repository.fetchAttendances()
  }

  public func fetchSchedules() async throws(MyPageError) -> [AttendanceMyScheduleResponse] {
    try await repository.fetchSchedules()
  }
}

extension MyPageUseCaseImpl: DependencyKey {
  public static var liveValue: any MyPageUseCaseInterface {
    @Dependency(\.myPageRepository) var repository
    return MyPageUseCaseImpl(repository: repository)
  }

  public static var testValue: any MyPageUseCaseInterface = liveValue
  public static var previewValue: any MyPageUseCaseInterface = liveValue
}

public extension DependencyValues {
  var myPageUseCase: any MyPageUseCaseInterface {
    get { self[MyPageUseCaseImpl.self] }
    set { self[MyPageUseCaseImpl.self] = newValue }
  }
}
