//
//  AttendanceRepositoryImpl.swift
//  Repository
//
//  Created by Wonji Suh  on 7/23/25.
//

import DomainInterface
import Model

import Service

@preconcurrency import AsyncMoya

@Observable
final public class AttendanceRepositoryImpl: AttendanceInterface , Sendable {
  private let provider: MoyaProvider<AttendanceService>

  public init(
    provider: MoyaProvider<AttendanceService> = MoyaProvider<AttendanceService>.withSession(AuthInterceptor.shared)
  ) {
    self.provider = provider
  }


  

  // MARK: - 출석 카운트 API
  public func attendanceCount(
    startDate: String
  ) async throws -> AttendanceCountResponseModel? {
    let response : BaseResponseDTO<AttendanceCountResponseDTO> = try await provider.request(
      .attendanceCount(startDate: startDate),
    )
    return response.data.toDomain()
  }

  // MARK: - 출석 목록 조회
  public func getAttendances(
    startDate: String,
    endDate: String
  ) async throws -> AttendanceListModel? {
    let attendanceModel : AttendanceListResponseDTOModel = try await provider.request(
      .getAttendances(startDate: startDate, endDate: endDate),
    )
    return attendanceModel.toDomain()
  }

  // MARK: - 팀별로 필터링  출석 목록
  public func fillAttendance(
    team: SelectTeam,
    startDate: String
  ) async throws -> AttendanceListModel? {
    let attendanceModel : AttendanceListResponseDTOModel = try await provider.request(
      .filterAttendance(startDate: startDate, team: team.rawValue)
    )
    return attendanceModel.toDomain()
  }

  // MARK: - 출석 할 목록 조회
  public func filterScheduleAttendance(
    userId: Int,
    scheduleId: String,
    startDate: String
  ) async throws -> AttendanceListModel? {
    let filterScheduleAttendanceModel: AttendanceListResponseDTOModel = try await provider.request(
      .filterScheduleAttendance(
        userId: userId,
        scheduleId: scheduleId,
        startDate: startDate
      ),
    )
    return filterScheduleAttendanceModel.toDomain()
  }

  // MARK: - qr 검증후 출석 수정
  public func modifyAttendance(
    attendanceId: String
  ) async throws -> ModifyAttendanceModel? {
    let modifyAttendanceModel: ModifyDTOAttendanceModel = try await provider.request(
      .modifyAttendance(attendanceId: attendanceId),
    )
    return modifyAttendanceModel.toDomain()
  }

  public func fetchCount(userID: Int) async throws -> AttendanceCountResponseModel {
    let response: BaseResponseDTO<AttendanceCountResponseDTO> = try await provider.request(
      .fetchCount(userID: userID)
    )
    return response.data.toDomain()
  }
}

