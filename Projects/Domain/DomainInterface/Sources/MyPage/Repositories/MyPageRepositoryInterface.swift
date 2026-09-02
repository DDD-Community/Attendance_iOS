//
//  MyPageRepositoryInterface.swift
//  DomainInterface
//
//  Created by DDD on 1/12/26.
//

import Foundation

import Dependencies

import Entity


public protocol MyPageRepositoryInterface: Sendable {
  /// 출석 현황 요약 조회
  func fetchAttendances() async throws(MyPageError) -> AttendanceSummaryResponse
  /// 전체 스케줄/출석 현황 조회
  func fetchSchedules() async throws(MyPageError) -> [AttendanceMyScheduleResponse]
}

public enum MyPageRepositoryDependency: TestDependencyKey {
  
  public static var testValue: any MyPageRepositoryInterface {
    DefaultMyPageRepository()
  }
  
  public static let previewValue: any MyPageRepositoryInterface = testValue
}

public extension DependencyValues {
  var myPageRepository: any MyPageRepositoryInterface {
    get { self[MyPageRepositoryDependency.self] }
    set { self[MyPageRepositoryDependency.self] = newValue }
  }
}
