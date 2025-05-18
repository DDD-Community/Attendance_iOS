//
//  AttendanceRepository.swift
//  UseCase
//
//  Created by Wonji Suh  on 5/10/25.
//

import Foundation
import Model

import Service

import AsyncMoya

@Observable
public class AttendanceRepository: AttendanceRepositoryProtocol {
  
  private let provider = MoyaProvider<AttendanceService>(plugins: [MoyaLoggingPlugin()])
  
  public init() {}
  
  // MARK: - 출석 카운트 API
  public func attendanceCount(
    startDate: String
  ) async throws -> AttendanceCountDTOModel? {
    let attendanceCountModel = try await provider.requestAsync(.attendanceCount(startDate: startDate), decodeTo: AttendanceCountModel.self)
    return attendanceCountModel.toAttendanceCountToDTOModel()
  }
  
  // MARK: - 출석 목록 조회
  public func getAttendances(
    startDate: String
  ) async throws -> AttendanceCheckModel? {
    let attendanceModel = try await provider.requestAsync(.getAttendances(startDate: startDate), decodeTo: AttendanceCheckDTOModel.self)
    return attendanceModel.toDomain()
  }
  
  // MARK: - 팀별로 필터링  출석 목록
  public func fillAttendance(
    team: SelectTeam,
    startDate: String
  ) async throws -> AttendanceCheckModel? {
    let attendanceModel = try await provider.requestAsync(
      .filterAttendance(startDate: startDate, team: team.rawValue), decodeTo: AttendanceCheckDTOModel.self)
    return attendanceModel.toDomain()
  }
  
  // MARK: - 출석 할 목록 조회
  public func filterScheduleAttendance(
    userId: Int,
    scheduleId: String
  ) async throws -> AttendanceCheckModel? {
    let filterScheduleAttendanceModel = try await provider.requestAsync(
      .filterScheduleAttendance(
        userId: userId,
        scheduleId: scheduleId
      ),
      decodeTo: AttendanceCheckDTOModel.self
    )
    return filterScheduleAttendanceModel.toDomain()
  }
  
  // MARK: - qr 검증후 출석 수정
  public func modifyAttendance(
    attendanceId: String
  ) async throws -> ModifyAttendanceModel? {
    let modifyAttendanceModel = try await provider.requestAsync(.modifyAttendance(attendanceId: attendanceId), decodeTo: ModifyDTOAttendanceModel.self)
    return modifyAttendanceModel.toDomain()

  // MARK: - 사용자 출석 카운트 조회
  public func fetchCount(userID: Int) async throws -> AttendanceCountResponseModel {
    let response = try await provider.requestAsync(.fetchCount(userID: userID), decodeTo: BaseResponseDTO<AttendanceCountResponseDTO>.self)
    return response.data.toDomain()
  }
}
