//
//  ScheduleModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/9/25.
//

import Foundation

public typealias ScheduleModel = BaseResponseDomain<[ScheduleResponseModel]>

// MARK: - Datum
public struct ScheduleResponseModel: Equatable {
  public var scheduleId : String
  public let title, description: String
  public let startTime, endTime: String
  public let attendancesSummary: [AttendancesSummary]
  
  public init(
    scheduleId: String,
    title: String,
    description: String,
    startTime: String,
    endTime: String,
    attendancesSummary: [AttendancesSummary]
  ) {
    self.scheduleId = scheduleId
    self.title = title
    self.description = description
    self.startTime = startTime
    self.endTime = endTime
    self.attendancesSummary = attendancesSummary
  }
  
}


public struct AttendancesSummary:  Equatable {
  public let profile: AttendanceProfile
  public let status, updatedAt: String
  public let method, note: String
  
  public init(
    profile: AttendanceProfile,
    status: String,
    updatedAt: String,
    method: String,
    note: String
  ) {
    self.profile = profile
    self.status = status
    self.updatedAt = updatedAt
    self.method = method
    self.note = note
  }
  
}

public struct AttendanceProfile:  Equatable {
  public let id: String
  public let userID: Int
  public  let name, role, cohort: String
  public let team: SelectTeam
  public  let responsibility: String
  
  public init(
    id: String,
    userID: Int,
    name: String,
    role: String,
    team: SelectTeam,
    cohort: String,
    responsibility: String
  ) {
    self.id = id
    self.userID = userID
    self.name = name
    self.role = role
    self.team = team
    self.cohort = cohort
    self.responsibility = responsibility
  }
  
}
