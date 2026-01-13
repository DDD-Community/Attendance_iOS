//
//  AttendanceRepositoryImpl.swift
//  Repository
//
//  Created by Wonji Suh  on 7/23/25.
//

import DomainInterface
import Model
import Entity

import Service

@preconcurrency import AsyncMoya

@Observable
final public class AttendanceRepositoryImpl: AttendanceInterface , Sendable {
  private let provider: MoyaProvider<AttendanceService>

  public init(
    provider: MoyaProvider<AttendanceService> = MoyaProvider<AttendanceService>.authorized
  ) {
    self.provider = provider
  }

  // MARK: - 운영진  출석 데이터 api
  public func adminAttendanceCount(scheduleId: Int) async throws -> AttendanceCount {
    let dto: AttendanceCountDTO  = try await provider.request(.adminAttendanceCount(scheduleId: scheduleId))
    return dto.toDomain()
  }

  // MARK: - 출석할 팀 조회
  public func fetchAttendanceTeams() async throws -> [SelectTeamEntity] {
    let dto: SelectTeamsDTO = try await provider.request(.fetchTeams)
    return dto.toDomain()
  }

  // MARK: - 출석 조회
  public func sessionAttendance(
    scheduleId: Int,
    teamId: Int
  ) async throws -> [Attendance] {
    let body = AttendanceRequestDTO(scheduleId: scheduleId, teamId: teamId)
    let dto: AttendanceDTOModel = try await provider.request(.sessionAttendance(body: body))
    return dto.toDomain()
  }

  // MARK: - 출석 status 조회
  public func fetchStatus() async throws -> [AttendanceStatus] {
    let dto: AttendanceStatusDTO = try await provider.request(.status)
    return dto.toDomain()
  }

  // MARK: - 출석변경
  public func editAttendance(
    input: EditAttendanceInput
  ) async throws -> EditAttendance {
    let request = EditAttendanceRequestDTO(
      attendanceId: input.attendanceId,
      status: input.status.rawValue,
      userId: input.userId
    )
    let response = try await provider.requestResponse(.editAttendance(body: request))
    let decoder = JSONDecoder()

    if (200...299).contains(response.statusCode) {
      if response.data.isEmpty {
        return EditAttendance(isSuccess: true)
      }
      if let successDTO = try? decoder.decode(EditAttendanceDTO.self, from: response.data) {
        return successDTO.toDomain(isSuccess: true)
      }
      return EditAttendance(isSuccess: true)
    }

    if let errorDTO = try? decoder.decode(EditAttendanceDTO.self, from: response.data) {
      return errorDTO.toDomain(isSuccess: false)
    }
    return EditAttendance(
      isSuccess: false,
      message: String(data: response.data, encoding: .utf8)
    )
  }
}
