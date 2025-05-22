//
//  AttendanceCheckDTOModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/15/25.
//

import Foundation

public typealias AttendanceListModel = BaseResponseDTO<[AttendanceListResponseModel]>

public struct AttendanceListResponseModel: Decodable, Equatable {
  public let id: String
  public let profileSummary: ProfileSummary
  public let scheduleSummary: ScheduleSummary
  public let updatedAt: String
  public let method: String
  public let note: String
  public let status: String?

  public init(
    id: String,
    profileSummary: ProfileSummary,
    scheduleSummary: ScheduleSummary,
    updatedAt: String,
    status: String?,
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
public struct ProfileSummary: Decodable, Equatable {
  public let name: String
  public let role: SelectPart?
  public let team: SelectTeam?
  public let cohort: String?
  public let crew: SelectTeam?

  public init(
    name: String,
    role: SelectPart?,
    team: SelectTeam?,
    cohort: String?,
    crew: SelectTeam?
  ) {
    self.name = name
    self.role = role
    self.team = team
    self.cohort = cohort
    self.crew = crew
  }
}

// MARK: - ScheduleSummary
public struct ScheduleSummary: Decodable, Equatable {
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

public extension AttendanceListResponseModel {
  func toSchedule() -> Schedule? {
    let formatter = ISO8601DateFormatter()
    guard let date = formatter.date(from: scheduleSummary.startTime) else {
      return nil
    }

    let calendar = Calendar.current
    let components = calendar.dateComponents([.month, .day], from: date)

    guard let month = components.month, let day = components.day else {
      return nil
    }

    return .init(
      id: id,
      month: month,
      day: day,
      title: scheduleSummary.title,
      description: scheduleSummary.description,
      status: .init(rawValue: status ?? "") ?? .tbd
    )
  }
}
