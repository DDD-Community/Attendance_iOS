//
//  Extension+ScheduleModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/9/25.
//

import Foundation

// MARK: - DTO -> Domain 변환 확장
public extension ScheduleDTOModel {
  /// DTO를 도메인 모델로 변환
  /// - Returns: ScheduleModel 인스턴스
  func toDomain() -> ScheduleModel {
    // 1) attendances_summary 변환
    let responses: [ScheduleResponseModel] = (self.data ?? []).map { item in
      // AttendancesSummaryDTO Optional 배열 처리
      let attendances: [AttendancesSummary] = item.attendancesSummary?.map { dto in
        let profileDTO = dto.profile
        // Profile 변환
        let profile = AttendanceProfile(
          id: profileDTO.id,
          userID: profileDTO.userID,
          name: profileDTO.name,
          role: profileDTO.role,
          team: SelectTeam(rawValue: profileDTO.team) ?? .notTeam,
          cohort: profileDTO.cohort,
          responsibility: profileDTO.responsibility
        )
        // AttendancesSummary 변환
        return AttendancesSummary(
          profile: profile,
          status: dto.status,
          updatedAt: dto.updatedAt,
          method: dto.method ?? "",
          note: dto.note ?? ""
        )
      } ?? []

      // ScheduleResponseModel 생성
      return ScheduleResponseModel(
        scheduleId: item.id ?? "",
        title: item.title ?? "",
        description: item.description ?? "",
        startTime: item.startTime ?? "",
        endTime: item.endTime ?? "",
        attendancesSummary: attendances
      )
    }

    // 최종 ScheduleModel 반환
    return ScheduleModel(
      code: self.code ?? 0,
      message: self.message ?? "",
      data: responses
    )
  }
}
