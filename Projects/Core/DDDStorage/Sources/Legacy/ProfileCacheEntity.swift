// 1.0.9(067600a4)의 저장 속성과 모델 이름을 유지하는 읽기 전용 호환 모델.
import Foundation
import SwiftData

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
}
