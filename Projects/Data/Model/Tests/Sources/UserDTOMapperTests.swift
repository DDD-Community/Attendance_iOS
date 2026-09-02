//
//  UserDTOMapperTests.swift
//  ModelTests
//
//  Created by DDD on 2026-09-02.
//

import Testing

import Entity
@testable import Model

@Suite("UserDTO Mapper")
struct UserDTOMapperTests {
  @Test("DTO의 기본 토큰과 사용자 식별 값을 User 엔티티로 전달한다")
  func mapsIdentityAndTokens() {
    let dto = UserDTO(
      userEmail: "member@ddd.kr",
      userName: "김철수",
      signUpName: "철수",
      userUid: "uid-1",
      accessToken: "access-token",
      refreshToken: "refresh-token",
      inviteCodeId: "invite-1"
    )

    let user = dto.toDomain()

    #expect(user.userEmail == "member@ddd.kr")
    #expect(user.userName == "김철수")
    #expect(user.signUpName == "철수")
    #expect(user.userUid == "uid-1")
    #expect(user.accessToken == "access-token")
    #expect(user.refreshToken == "refresh-token")
    #expect(user.inviteCodeId == "invite-1")
  }

  @Test("DTO의 API 문자열 enum을 도메인 enum으로 변환한다")
  func mapsApiEnumsToDomainEnums() {
    let dto = UserDTO(
      userRole: Entity.UserRole.member,
      managing: Model.Managing.attendanceCheck,
      role: Model.SelectPart.web,
      memberTeam: Model.SelectTeam.ios1,
      staffRole: Entity.Staff.manager
    )

    let user = dto.toDomain()

    #expect(user.userRole == Entity.UserRole.member)
    #expect(user.managing == Entity.StaffManaging.attendanceCheck)
    #expect(user.role == Entity.SelectParts.frontend)
    #expect(user.memberTeam == Entity.SelectTeams.ios1)
    #expect(user.staffRole == Entity.Staff.manager)
  }

  @Test("DTO의 선택 값이 없으면 User 엔티티도 nil을 유지한다")
  func keepsOptionalEnumsNil() {
    let dto = UserDTO(
      userRole: nil,
      managing: nil,
      role: nil,
      memberTeam: nil,
      staffRole: nil
    )

    let user = dto.toDomain()

    #expect(user.userRole == nil)
    #expect(user.managing == nil)
    #expect(user.role == nil)
    #expect(user.memberTeam == nil)
    #expect(user.staffRole == nil)
  }
}
