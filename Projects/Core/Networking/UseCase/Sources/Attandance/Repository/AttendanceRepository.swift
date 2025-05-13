//
//  AttendanceRepository.swift
//  UseCase
//
//  Created by Wonji Suh  on 5/10/25.
//

import Model

import Service

import AsyncMoya

@Observable
public class AttendanceRepository: AttendanceRepositoryProtocol {
  
  private let provider = MoyaProvider<AttendanceService>(plugins: [MoyaLoggingPlugin()])
  
  
  public init(){}
  
  // MARK: - 출석 카운트 API
  public func attendanceCount(
    startDate: String
  ) async throws -> AttendanceCountDTOModel? {
    let attendanceCountModel = try await provider.requestAsync(.attendanceCount(startDate: startDate), decodeTo: AttendanceCountModel.self)
    return attendanceCountModel.toAttendanceCountToDTOModel()
  }
}
