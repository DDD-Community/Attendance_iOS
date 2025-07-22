//
//  Extension+QRValidateDTOModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/20/25.
//

import Foundation

public extension QRValidateDTOModel {
  func toDomain() -> QRValidateModel {
    let profile = self.data.profileSummary
    let schedule =  self.data.scheduleSummary

    let profileModel = ProfileSummary(
      name: profile.name,
      role: SelectPart(rawValue: profile.role ?? "") ?? .all,
      team: SelectTeam(rawValue: profile.team ?? "") ?? .notTeam,
      cohort: profile.cohort ?? "",
      crew: SelectTeam(rawValue: profile.crew ?? "") ?? .notTeam
    )

    let scheduleModel = ScheduleSummary(
      scheduleId: schedule.id ?? "",
      title: schedule.title ?? "",
      description: schedule.description ?? "",
      startTime: schedule.startTime ?? ""
    )

    let data = QRValidateResponseModel(
      id: self.data.id,
      profileSummary: profileModel,
      scheduleSummary: scheduleModel,
      updatedAt: self.data.updatedAt,
      status: self.data.status,
      method: self.data.method,
      note: self.data.note ?? ""
      )

    
    return QRValidateModel(
      code: self.code,
      message: self.message,
      data: data
    )
  }
}
