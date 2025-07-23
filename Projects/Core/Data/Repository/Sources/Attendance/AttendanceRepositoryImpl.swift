//
//  AttendanceRepositoryImpl.swift
//  Repository
//
//  Created by Wonji Suh  on 7/23/25.
//

import DomainInterface
import Model

import Service

import AsyncMoya

@Observable
public class AttendanceRepositoryImpl: AttendanceInterface {
  private let provider = MoyaProvider<AttendanceService>(plugins: [MoyaLoggingPlugin()])

  public init(){}

  // MARK: - 출석 카운트 API
  public func attendanceCount(
    startDate: String
  ) async throws -> AttendanceCountResponseModel? {
    let response = try await provider.requestAsync(
      .attendanceCount(startDate: startDate),
      decodeTo: BaseResponseDTO<AttendanceCountResponseDTO>.self
    )
    return response.data.toDomain()
  }

  // MARK: - 출석 목록 조회
  public func getAttendances(
    startDate: String,
    endDate: String
  ) async throws -> AttendanceListModel? {
    let attendanceModel = try await provider.requestAsync(
      .getAttendances(startDate: startDate, endDate: endDate),
      decodeTo: AttendanceListResponseDTOModel.self
    )
    return attendanceModel.toDomain()
  }

  // MARK: - 팀별로 필터링  출석 목록
  public func fillAttendance(
    team: SelectTeam,
    startDate: String
  ) async throws -> AttendanceListModel? {
    let attendanceModel = try await provider.requestAsync(
      .filterAttendance(startDate: startDate, team: team.rawValue),
      decodeTo: AttendanceListResponseDTOModel.self
    )
    return attendanceModel.toDomain()
  }

  // MARK: - 출석 할 목록 조회
  public func filterScheduleAttendance(
    userId: Int,
    scheduleId: String,
    startDate: String
  ) async throws -> AttendanceListModel? {
    let filterScheduleAttendanceModel = try await provider.requestAsync(
      .filterScheduleAttendance(
        userId: userId,
        scheduleId: scheduleId,
        startDate: startDate
      ),
      decodeTo: AttendanceListResponseDTOModel.self
    )
    return filterScheduleAttendanceModel.toDomain()
  }

  // MARK: - qr 검증후 출석 수정
  public func modifyAttendance(
    attendanceId: String
  ) async throws -> ModifyAttendanceModel? {
    let modifyAttendanceModel = try await provider.requestAsync(
      .modifyAttendance(attendanceId: attendanceId),
      decodeTo: ModifyDTOAttendanceModel.self
    )
    return modifyAttendanceModel.toDomain()
  }

  public func fetchCount(userID: Int) async throws -> AttendanceCountResponseModel {
    let response = try await provider.requestAsync(
      .fetchCount(userID: userID),
      decodeTo: BaseResponseDTO<AttendanceCountResponseDTO>.self
    )
    return response.data.toDomain()
  }
}

