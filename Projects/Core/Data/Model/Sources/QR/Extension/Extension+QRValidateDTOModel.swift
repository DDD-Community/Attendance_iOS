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

    let profileModel = QRProfileSummary(
      id: profile.id,
      userID: profile.userID,
      name: profile.name,
      role: SelectPart(rawValue: profile.role) ?? .all,
      team: SelectTeam(rawValue: profile.team) ?? .notTeam,
      cohort: profile.cohort
    )

    let scheduleModel = QRScheduleSummary(
      id: schedule.id,
      title: schedule.title,
      description: schedule.description,
      startTime: schedule.startTime,
      endTime: schedule.endTime
    )

    let data = QRValidateResponseModel(
      id: self.data.id,
      profileSummary: profileModel,
      scheduleSummary: scheduleModel,
      updatedAt: self.data.updatedAt,
      method: self.data.status,
      note: self.data.method,
      status: AttendanceType(rawValue: self.data.status) ?? .notAttendance
      )

    
    return QRValidateModel(
      code: self.code,
      message: self.message,
      data: data
    )
  }
}
