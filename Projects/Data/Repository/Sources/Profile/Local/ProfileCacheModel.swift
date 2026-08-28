//
//  ProfileCacheModel.swift
//  Repository
//
//  Created by DDD on 5/12/26.
//

import Foundation
import SwiftData

import Entity

@Model
final class ProfileCacheEntity {
  @Attribute(.unique) var cacheKey: String
  var cachedAt: Date

  var userID: Int
  var name: String
  var generation: String
  var teamRawValue: String?
  var jobRoleRawValue: String
  var roleRawValue: String
  var managerRolesRawValues: [String]?

  init(
    cacheKey: String,
    cachedAt: Date,
    userID: Int,
    name: String,
    generation: String,
    teamRawValue: String?,
    jobRoleRawValue: String,
    roleRawValue: String,
    managerRolesRawValues: [String]?
  ) {
    self.cacheKey = cacheKey
    self.cachedAt = cachedAt
    self.userID = userID
    self.name = name
    self.generation = generation
    self.teamRawValue = teamRawValue
    self.jobRoleRawValue = jobRoleRawValue
    self.roleRawValue = roleRawValue
    self.managerRolesRawValues = managerRolesRawValues
  }

  // 만료: 당일
  var isExpired: Bool {
    !Calendar.current.isDate(cachedAt, inSameDayAs: Date())
  }

  func toDomain() -> ProfileEntity {
    ProfileEntity(
      userID: userID,
      name: name,
      generation: generation,
      team: teamRawValue.flatMap { SelectTeams(rawValue: $0) },
      jobRole: SelectParts(rawValue: jobRoleRawValue) ?? .all,
      role: Staff(rawValue: roleRawValue) ?? .member,
      manger: managerRolesRawValues?.compactMap { StaffManaging(rawValue: $0) }
    )
  }
}

extension ProfileEntity {
  func toCacheModel(cacheKey: String) -> ProfileCacheEntity {
    ProfileCacheEntity(
      cacheKey: cacheKey,
      cachedAt: Date(),
      userID: userID,
      name: name,
      generation: generation,
      teamRawValue: team?.rawValue,
      jobRoleRawValue: jobRole.rawValue,
      roleRawValue: role.rawValue,
      managerRolesRawValues: manger?.map { $0.rawValue }
    )
  }
}

enum ProfileCacheKey {
  static let user = "profile.user.default"
}
