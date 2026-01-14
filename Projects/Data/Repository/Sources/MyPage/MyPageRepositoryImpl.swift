//
//  MyPageRepositoryImpl.swift
//  Repository
//
//  Created by 홍은표 on 1/12/26.
//

import Foundation

import DomainInterface

import Entity
import Service

@preconcurrency import AsyncMoya

final public class MyPageRepositoryImpl: MyPageRepositoryInterface {
  private let provider: MoyaProvider<MyPageService>
  
  public init(
    provider: MoyaProvider<MyPageService> = .authorized
  ) {
    self.provider = provider
  }
  
  /// 출석 현황 요약 조회
  public func fetchAttendances() async throws -> AttendanceSummaryResponse {
    let response: AttendanceSummaryResponseDTO = try await provider.request(.fetchAttendances)
    return response.toDomain()
  }
}
