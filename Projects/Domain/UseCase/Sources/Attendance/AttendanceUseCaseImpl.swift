//
//  AttendanceUseCaseImpl.swift
//  UseCase
//
//  Created by Wonji Suh  on 7/23/25.
//

import DomainInterface
import Model
import Repository

import ComposableArchitecture
import WeaveDI

public struct AttendanceUseCaseImpl: AttendanceInterface {
  private let repository: AttendanceInterface

  public init(
    repository: AttendanceInterface
  ) {
    self.repository = repository
  }

  // MARK: - 출석 현황 카운트 api
  public func attendanceCount(
    startDate: String
  ) async throws -> AttendanceCountResponseModel? {
    return try await repository.attendanceCount(startDate: startDate)
  }

  // MARK: - 출석 목록 조회
  public func getAttendances(
    startDate: String,
    endDate: String
  ) async throws -> AttendanceListModel? {
    return try await repository.getAttendances(startDate: startDate, endDate: endDate)
  }

  // MARK: - 팀별로 출석 조회
  public func fillAttendance(
    team: SelectTeam,
    startDate: String
  ) async throws -> AttendanceListModel? {
    return try await repository.fillAttendance(team: team, startDate: startDate)
  }

  // MARK: - 스케줄 아이디로 출석 조회 필터
  public func filterScheduleAttendance(
    userId: Int,
    scheduleId: String,
    startDate: String
  ) async throws -> AttendanceListModel? {
    return try await repository.filterScheduleAttendance(
      userId: userId,
      scheduleId: scheduleId,
      startDate: startDate
    )
  }

  // MARK: - 출석 수정
  public func modifyAttendance(
    attendanceId: String
  ) async throws -> ModifyAttendanceModel? {
    return try await repository.modifyAttendance(attendanceId: attendanceId)
  }

  // MARK: - 사용자 출석 카운트 조회
  public func fetchCount(userID: Int) async throws -> AttendanceCountResponseModel {
    return try await repository.fetchCount(userID: userID)
  }
}

extension AttendanceUseCaseImpl: DependencyKey {
  static public var liveValue: AttendanceInterface = {
    let repository = UnifiedDI.register(AttendanceInterface.self) {
      AttendanceRepositoryImpl()
    }
    return AttendanceUseCaseImpl(repository: repository)
  }()
}

public extension DependencyValues {
  var sattendanceUseCase: AttendanceInterface {
    get { self[AttendanceUseCaseImpl.self] }
    set { self[AttendanceUseCaseImpl.self] = newValue }
  }
}


