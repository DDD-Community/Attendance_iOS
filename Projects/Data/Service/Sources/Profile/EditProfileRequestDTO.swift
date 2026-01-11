//
//  EditProfileRequestDTO.swift
//  Service
//
//  Created by Wonji Suh on 1/6/26.
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

    // 역할에 따른 managerRoles 처리
    // Manager일 경우: managerRoles 포함 (null 가능)
    // Member일 경우: managerRoles 필드 제거
    if let managerRoles = profile.managerRoles, !managerRoles.isEmpty {
      // Manager: managerRoles 배열 포함
      try container.encode(managerRoles, forKey: .managerRoles)
    } else if profile.managerRoles != nil {
      // Manager이지만 managerRoles가 빈 배열인 경우: null 포함
      try container.encodeNil(forKey: .managerRoles)
    }
    // Member인 경우 (managerRoles == nil): 필드 자체를 포함하지 않음

    try container.encode(profile.invitationCode, forKey: .invitationCode)
  }

  private enum CodingKeys: String, CodingKey {
    case name, generationId, jobRole, teamId, managerRoles, invitationCode
  }
}
