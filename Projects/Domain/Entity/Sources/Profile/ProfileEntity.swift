//
//  ProfileEntity.swift
//  Entity
//
//  Created by Wonji Suh  on 1/4/26.
//

import Foundation

public struct ProfileEntity: Equatable {
  public let userID: Int
  public let name: String
  public let generation: String
  public let team: SelectTeams?
  public let jobRole: SelectParts
  public let role: Staff
  public let manger: [StaffManaging]?

  public init(
    userID: Int,
    name: String,
    generation: String,
    team: SelectTeams?,
    jobRole: SelectParts,
    role: Staff,
    manger: [StaffManaging]?
  ) {
    self.userID = userID
    self.name = name
    self.generation = generation
    self.team = team
    self.jobRole = jobRole
    self.role = role
    self.manger = manger
  }
}

// MARK: - Mock Data
public extension ProfileEntity {
  static func mockData() -> ProfileEntity {
    return ProfileEntity(
      userID: 1,
      name: "김철수",
      generation: "1기",
      team: .ios1,
      jobRole: .ios,
      role: .manager,
      manger: [.teamManaging, .scheduleReminder]
    )
  }

  static func mockMemberUser() -> ProfileEntity {
    return ProfileEntity(
      userID: 2,
      name: "이영희",
      generation: "2기",
      team: .and1,
      jobRole: .android,
      role: .member,
      manger: nil
    )
  }

  static func mockManagerUser() -> ProfileEntity {
    return ProfileEntity(
      userID: 3,
      name: "박민수",
      generation: "1기",
      team: .web1,
      jobRole: .frontend,
      role: .manager,
      manger: [.attendanceCheck, .photo, .snsManagement]
    )
  }

  static func mockNewGenUser() -> ProfileEntity {
    return ProfileEntity(
      userID: 4,
      name: "최지은",
      generation: "3기",
      team: .ios2,
      jobRole: .ios,
      role: .member,
      manger: nil
    )
  }
}