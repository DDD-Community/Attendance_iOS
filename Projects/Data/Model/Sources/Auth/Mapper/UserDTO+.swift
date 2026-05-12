//
//  UserDTO+.swift
//  Model
//
//  Created by Wonji Suh on 5/12/26.
//

import Entity

public extension UserDTO {
  func toDomain() -> User {
    return User(
      userEmail: userEmail,
      userName: userName,
      signUpName: signUpName,
      userUid: userUid,
      accessToken: accessToken,
      refreshToken: refreshToken,
      inviteCodeId: inviteCodeId,
      userRole: userRole,
      managing: managing.flatMap { StaffManaging(rawValue: $0.rawValue.uppercased()) },
      role: role.flatMap { SelectParts(rawValue: $0.rawValue) },
      memberTeam: memberTeam.flatMap { SelectTeams(rawValue: $0.rawValue) },
      staffRole: staffRole
    )
  }
}
