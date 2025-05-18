//
//  Extension+AttendanceCheckModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/15/25.
//

import Foundation

public extension AttendanceCheckDTOModel {
  func toAttendanceCheckDTOToModel() -> AttendanceCheckModel {
    let profileDTO = ProfileSummaryResponse(
      name: self.data?.profileSummary.name ?? "",
      role:  self.data?.profileSummary.role ?? "",
      team:  self.data?.profileSummary.team ?? ""
    )
    
    let scheduleDTO = ScheduleSummaryResponse(
      scheduleId: self.data?.scheduleSummary.id ?? "",
      title: self.data?.scheduleSummary.title ?? "",
      description: self.data?.scheduleSummary.description ?? "",
      startTime: self.data?.scheduleSummary.startTime ?? ""
    )
    
    let data = AttendanceCheckResponseModel(
      id: self.data?.id ?? "",
      profileSummary: profileDTO,
      scheduleSummary: scheduleDTO,
      updatedAt: self.data?.updatedAt ?? "",
      status: AttendanceStatus(rawValue: self.data?.status ?? ""),
      method: self.data?.method ?? "",
      note: self.data?.note ?? ""
    )
    
    return AttendanceCheckModel(
      code: self.code ?? .zero,
      message: self.message ?? "",
      data: data
    )
  }
}
