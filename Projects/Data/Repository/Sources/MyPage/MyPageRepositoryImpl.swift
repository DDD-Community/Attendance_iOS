//
//  MyPageRepositoryImpl.swift
//  Repository
//
//  Created by DDD on 1/12/26.
//

import Foundation
// 프로젝트 모듈
import DomainInterface
import Entity
import Service
// 외부 의존성
import Moya

final public class MyPageRepositoryImpl: MyPageRepositoryInterface {
  private let provider: MoyaProvider<MyPageService>

  public init(
    provider: MoyaProvider<MyPageService>? = nil
  ) {
    // 🚀 MoyaProviderPool 사용으로 메모리 최적화
    self.provider = provider ?? MoyaProviderPool.shared.authorizedProvider(for: MyPageService.self)

  }
  
  /// 출석 현황 요약 조회
  public func fetchAttendances() async throws -> AttendanceSummaryResponse {
    let response: AttendanceSummaryResponseDTO = try await provider.request(.fetchAttendances)
    return response.toDomain()
  }
  
  /// 내 스케줄/출석 현황 조회
  public func fetchSchedules() async throws -> [AttendanceMyScheduleResponse] {
    let response: [AttendanceMyScheduleResponseDTO] = try await provider.request(.fetchSchedules)
    return response.map { $0.toDomain() }
  }
}
