//
//  SignUpUserInput+Extensions.swift
//  Repository
//
//  Created by Claude on 1/6/26.
//

import Foundation
import Entity
import Service

// MARK: - SignUpUserInput → SignUpUserRequestDTO 변환
extension SignUpUserInput {
  /// SignUpUserInput에서 SignUpUserRequestDTO로 변환
  public func toRequestDTO() -> SignUpUserRequestDTO {
    return SignUpUserRequestDTO(
      name: name,
      generationId: generationId,
      jobRole: jobRole.apiKey,
      teamId: teamId,
      managerRoles: managerRoles?.map { $0.apiKey },
      provider: provider.description,
      token: token,
      invitationCode: invitationCode
    )
  }

  /// 구조화된 방식으로 변환 (BaseUserProfileDTO 사용)
  public func toStructuredRequestDTO() -> SignUpUserRequestDTO {
    let profile = BaseUserProfileDTO(
      name: name,
      generationId: generationId,
      jobRole: jobRole.apiKey,
      teamId: teamId,
      managerRoles: managerRoles?.map { $0.apiKey },
      invitationCode: invitationCode
    )

    let authentication = AuthenticationDTO(
      provider: provider.description,
      token: token,
    )

    return SignUpUserRequestDTO(
      profile: profile,
      authentication: authentication
    )
  }
}
