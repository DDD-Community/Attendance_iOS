//
//  EditProfileRequestDTO.swift
//  Service
//
//  Created by Claude on 1/6/26.
//

import Foundation

public struct EditProfileRequestDTO: Encodable {
  public let profile: BaseUserProfileDTO

  public init(
    profile: BaseUserProfileDTO
  ) {
    self.profile = profile
  }

  // 편의 이니셜라이저
  public init(
    name: String,
    generationId: Int,
    jobRole: String,
    teamId: Int?,
    managerRoles: [String]?,
    invitationCode: String
  ) {
    self.profile = BaseUserProfileDTO(
      name: name,
      generationId: generationId,
      jobRole: jobRole,
      teamId: teamId,
      managerRoles: managerRoles,
      invitationCode: invitationCode
    )
  }

  // Flat 구조로 인코딩하기 위한 커스텀 인코딩
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encode(profile.name, forKey: .name)
    try container.encode(profile.generationId, forKey: .generationId)
    try container.encode(profile.jobRole, forKey: .jobRole)
    try container.encode(profile.teamId, forKey: .teamId)
    try container.encode(profile.managerRoles, forKey: .managerRoles)
    try container.encode(profile.invitationCode, forKey: .invitationCode)
  }

  private enum CodingKeys: String, CodingKey {
    case name, generationId, jobRole, teamId, managerRoles, invitationCode
  }
}

// MARK: - Dictionary 변환 (SignUpUserRequestDTO와 동일)
extension EditProfileRequestDTO {
  /// DTO를 Dictionary로 변환 (Moya parameters용)
  public var toDictionary: [String: Any]? {
    guard let data = try? JSONEncoder().encode(self) else { return nil }
    return try? JSONSerialization.jsonObject(with: data) as? [String: Any]
  }
}
