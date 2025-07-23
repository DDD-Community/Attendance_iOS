//
//  Extension+ScheduleModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/9/25.
//

import Foundation

// MARK: - DTO -> Domain 변환 확장
public extension ScheduleDTOModel {
  func toDomain() -> ScheduleModel {
    let responses: [ScheduleResponseModel] = (self.data ?? []).map { item in
      let attendances: [AttendancesSummary] = item.attendancesSummary?.compactMap { dto in
        guard let profileDTO = dto.profile else {
          return .none // ❗ profile이 null이면 해당 attendance 생략
        }

        let profile = AttendanceProfile(
          id: profileDTO.id,
          userID: profileDTO.userID,
          name: profileDTO.name,
          role: profileDTO.role,
          team: SelectTeam(rawValue: profileDTO.team) ?? .notTeam,
          cohort: profileDTO.cohort,
          responsibility: profileDTO.responsibility
        )

        return AttendancesSummary(
          profile: profile,
          status: dto.status ?? "",
          updatedAt: dto.updatedAt ?? "",
          method: dto.method ?? "",
          note: dto.note ?? ""
        )
      } ?? []

      return ScheduleResponseModel(
        scheduleId: item.id ?? "",
        title: item.title ?? "",
        description: item.description ?? "",
        startTime: item.startTime ?? "",
        endTime: item.endTime ?? "",
        attendancesSummary: attendances
      )
    }

    return ScheduleModel(
      code: self.code ?? 0,
      message: self.message ?? "",
      data: responses
    )
  }
}
