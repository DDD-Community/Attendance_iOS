//
//  Extension+ModifyDTOAttendanceModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/20/25.
//

import Foundation

public extension ModifyDTOAttendanceModel {
  func toDomain() -> ModifyAttendanceModel {
    let profileSummary = ProfileSummaryResponse(
      name: self.data?.profileSummary?.name ?? "",
      role: SelectPart(rawValue: self.data?.profileSummary?.role ?? ""),
      team: SelectTeam(rawValue: self.data?.profileSummary?.team ?? ""),
      cohort: self.data?.profileSummary?.cohort ?? "",
      crew: SelectTeam(rawValue: self.data?.profileSummary?.crew ?? "")
    )
    
    let scheduleSummary = ScheduleSummaryResponse(
      scheduleId:  self.data?.scheduleSummary?.id ?? "",
      title:  self.data?.scheduleSummary?.title ?? "",
      description: self.data?.scheduleSummary?.description ?? "",
      startTime: self.data?.scheduleSummary?.startTime ?? ""
    )
    
    let data = ModifyAttendanceResponseModel(
      id: self.data?.id ?? "",
      profileSummary: profileSummary,
      scheduleSummary: scheduleSummary,
      method: self.data?.method ?? "",
      note: self.data?.note ?? "",
      status: AttendanceType(rawValue: self.data?.status ?? "") ?? .present
    )
    
    return ModifyAttendanceModel(
      code: self.code ?? .zero,
      message: self.message ?? "",
      data: data
    )
  }
}
