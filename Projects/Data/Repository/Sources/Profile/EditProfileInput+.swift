//
//  EditProfileInput+.swift
//  Repository
//
//  Created by Wonji Suh  on 1/6/26.
//

import Entity
import Service
// MARK: - DTO 변환 (SignUpUserInput 패턴과 동일)
public extension EditProfileInput {
  /// EditProfileRequestDTO로 변환 (registerUser 패턴과 동일)
  func toRequestDTO() -> EditProfileRequestDTO {
    return EditProfileRequestDTO(
      name: name,
      generationId: generationId,
      jobRole: jobRole.apiKey,
      teamId: teamId,
      managerRoles: managerRoles?.map { $0.apiKey },
      invitationCode: inviteCode
    )
  }
}


