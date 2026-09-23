//
//  MyPageUseCaseInterface.swift
//  MyPageDomainInterface
//
//  Created by DDD on 9/3/26.
//

import Dependencies

public protocol MyPageUseCaseInterface: Sendable {
  func fetchAttendances() async throws(MyPageError) -> AttendanceSummaryResponse
  func fetchSchedules() async throws(MyPageError) -> [AttendanceMyScheduleResponse]
}

extension MockMyPageRepository: MyPageUseCaseInterface {}

public enum MyPageUseCaseDependency: TestDependencyKey {
  public static let testValue: any MyPageUseCaseInterface = MockMyPageRepository()
  public static let previewValue: any MyPageUseCaseInterface = testValue
}

public extension DependencyValues {
  var myPageUseCase: any MyPageUseCaseInterface {
    get { self[MyPageUseCaseDependency.self] }
    set { self[MyPageUseCaseDependency.self] = newValue }
  }
}
