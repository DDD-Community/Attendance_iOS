//
//  AttendanceCheckDTOModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/15/25.
//

import Foundation

public typealias AttendanceCheckModel = BaseResponse<AttendanceCheckResponseModel>

public struct AttendanceCheckResponseModel: Decodable {
  public let id: String
  public let profileSummary: ProfileSummaryResponse
  public let scheduleSummary: ScheduleSummaryResponse
  public let updatedAt: String
  public let method, note: String
  public let status: AttendanceStatus?

  public init(
    id: String,
    profileSummary: ProfileSummaryResponse,
    scheduleSummary: ScheduleSummaryResponse,
    updatedAt: String,
    status: AttendanceStatus?,
    method: String,
    note: String
  ) {
    self.id = id
    self.profileSummary = profileSummary
    self.scheduleSummary = scheduleSummary
    self.updatedAt = updatedAt
    self.status = status
    self.method = method
    self.note = note
  }
}

// MARK: - ProfileSummary
public struct ProfileSummaryResponse: Decodable {
  public let name: String
  public let role, team: String
  
  public init(
    name: String,
    role: String,
    team: String
  ) {
    self.name = name
    self.role = role
    self.team = team
  }
  
}

// MARK: - ScheduleSummary
public struct ScheduleSummaryResponse: Decodable {
  public let scheduleId, title, description: String
  public let startTime: String
  
  public init(
    scheduleId: String,
    title: String,
    description: String,
    startTime: String
  ) {
    self.scheduleId = scheduleId
    self.title = title
    self.description = description
    self.startTime = startTime
  }
}
