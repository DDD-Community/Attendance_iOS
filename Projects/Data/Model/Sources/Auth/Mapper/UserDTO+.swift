//
//  UserDTO+.swift
//  Model
//
//  Created by DDD on 5/12/26.
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
      role: role.flatMap { SelectParts.from(apiKey: $0.rawValue) },
      memberTeam: memberTeam.map { team in
        switch team {
        case .ios1:
          return .ios1
        case .ios2:
          return .ios2
        case .and1:
          return .and1
        case .and2:
          return .and2
        case .web1:
          return .web1
        case .web2:
          return .web2
        case .notTeam, .unknown:
          return .unknown
        }
      },
      staffRole: staffRole
    )
  }
}
