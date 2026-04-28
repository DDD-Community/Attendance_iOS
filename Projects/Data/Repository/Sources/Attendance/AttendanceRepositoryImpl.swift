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
final public class AttendanceRepositoryImpl: AttendanceInterface, Sendable {
  private let provider: MoyaProvider<AttendanceService>

  public init(
    provider: MoyaProvider<AttendanceService>? = nil
  ) {
    // 🚀 MoyaProviderPool 사용으로 메모리 최적화
    self.provider = provider ?? MoyaProviderPool.shared.authorizedProvider(for: AttendanceService.self)

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
      attendanceId: input.attendanceId.map(String.init),
      status: input.status.rawValue,
      userId: input.userId,
      scheduleId: "\(input.scheduleId)"
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

    // 400+ 에러는 exception으로 throw
    if let errorDTO = try? decoder.decode(EditAttendanceDTO.self, from: response.data) {
      // 서버에서 온 상세 메시지 우선 사용
      let userMessage = errorDTO.message ?? "알 수 없는 오류가 발생했습니다"

      switch response.statusCode {
      case 400...499:
        // 클라이언트 오류 - 서버 메시지를 사용자에게 표시
        throw AttendanceError.unknown(userMessage)
      case 500...599:
        // 서버 오류
        throw AttendanceError.serverError(response.statusCode)
      default:
        throw AttendanceError.unknown(userMessage)
      }
    }

    // JSON 디코딩 실패 시
    let rawMessage = String(data: response.data, encoding: .utf8) ?? "디코딩 실패"
    throw AttendanceError.decodingError("응답 파싱 실패: \(rawMessage)")
  }
}
