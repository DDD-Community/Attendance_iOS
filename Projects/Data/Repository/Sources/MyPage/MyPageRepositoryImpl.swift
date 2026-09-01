//
//  MyPageRepositoryImpl.swift
//  Repository
//
//  Created by DDD on 1/12/26.
//

import Foundation
// 프로젝트 모듈
import DDDNetworkInterface
import DomainInterface
import Entity
import Model
import APIEndpoint

final public class MyPageRepositoryImpl: MyPageRepositoryInterface {
  private let client: any DDDNetworkClient

  public init(
    client: any DDDNetworkClient
  ) {
    self.client = client
  }
  
  /// 출석 현황 요약 조회
  public func fetchAttendances() async throws(MyPageError) -> AttendanceSummaryResponse {
    do {
      let response = try await client.send(
        MyPageService.fetchAttendances,
        as: AttendanceSummaryResponseDTO.self
      )
      return response.toDomain()
    } catch {
      throw MyPageError.from(error)
    }
  }
  
  /// 내 스케줄/출석 현황 조회
  public func fetchSchedules() async throws(MyPageError) -> [AttendanceMyScheduleResponse] {
    do {
      let response = try await client.send(
        MyPageService.fetchSchedules,
        as: [AttendanceMyScheduleResponseDTO].self
      )
      return response.map { $0.toDomain() }
    } catch {
      throw MyPageError.from(error)
    }
  }
}
