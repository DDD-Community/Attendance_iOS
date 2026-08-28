//
//  MyPageRepositoryInterface.swift
//  DomainInterface
//
//  Created by DDD on 1/12/26.
//

import Foundation

import Entity

import WeaveDI

public protocol MyPageRepositoryInterface: Sendable {
  /// 출석 현황 요약 조회
  func fetchAttendances() async throws -> AttendanceSummaryResponse
  /// 전체 스케줄/출석 현황 조회
  func fetchSchedules() async throws -> [AttendanceMyScheduleResponse]
}

public enum MyPageRepositoryDependency: DependencyKey {
  public static var liveValue: any MyPageRepositoryInterface {
    UnifiedDI.resolve(MyPageRepositoryInterface.self) ?? DefaultMyPageRepository()
  }
  
  public static var testValue: any MyPageRepositoryInterface {
    UnifiedDI.resolve(MyPageRepositoryInterface.self) ?? DefaultMyPageRepository()
  }
  
  public static let previewValue: any MyPageRepositoryInterface = liveValue
}

public extension DependencyValues {
  var myPageRepository: any MyPageRepositoryInterface {
    get { self[MyPageRepositoryDependency.self] }
    set { self[MyPageRepositoryDependency.self] = newValue }
  }
}
