//
//  Extension+AttendanceCheckDTOModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/15/25.
//

import Foundation

public extension AttendanceCheckDTOModel {
  func toDomain() -> AttendanceCheckModel {
     let data = self.data?.compactMap { item in
      let profile = item.profileSummary
      let schedule = item.scheduleSummary

      let profileModel = ProfileSummaryResponse(
        name: profile.name,
        role: SelectPart(rawValue: profile.role ?? "") ?? .all,
        team: SelectTeam(rawValue: profile.team ?? "") ?? .notTeam,
        cohort: profile.cohort ?? "",
        crew: SelectTeam(rawValue: profile.crew ?? "") ?? .notTeam
        
      )

      let scheduleModel = ScheduleSummaryResponse(
        scheduleId: schedule.id ?? "",
        title: schedule.title ?? "",
        description: schedule.description ?? "",
        startTime: schedule.startTime ?? ""
      )

      return AttendanceCheckResponseModel(
        id: item.id,
        profileSummary: profileModel,
        scheduleSummary: scheduleModel,
        updatedAt: item.updatedAt ?? "",
        status: item.status ?? "",
        method: item.method ?? "",
        note: item.note ?? ""
      )
    }

    return AttendanceCheckModel(
      code: self.code ?? 0,
      message: self.message ?? "",
      data: data ?? []
    )
  }
}
