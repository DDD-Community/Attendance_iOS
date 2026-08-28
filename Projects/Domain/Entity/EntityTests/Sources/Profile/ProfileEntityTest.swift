//
//  ProfileEntityTest.swift
//  EntityTests
//
//  Created by DDD on 2026-01-30
//

import Testing
@testable import Entity

@Suite("Profile Entity Tests")
struct ProfileEntityTest {

    @Test("ProfileEntity Mock 데이터 생성 테스트")
    func test_ProfileEntity_mock_data_creation() throws {
        // Given
        let profile = ProfileEntity.mockData()

        // Then
        #expect(profile.userID == 1)
        #expect(profile.name == "김철수")
        #expect(profile.generation == "1기")
        #expect(profile.team == .ios1)
        #expect(profile.jobRole == .ios)
        #expect(profile.role == .manager)
    }

    @Test("EditProfileInput Mock 데이터 테스트")
    func test_EditProfileInput_mock_data() throws {
        // Given
        let input = EditProfileInput.mockData()

        // Then
        #expect(input.name == "김철수")
        #expect(input.generationId == 1)
        #expect(input.jobRole == .ios)
        #expect(input.inviteCode == "INVITE_CODE_123")
    }

    @Test("Profile 매니저 사용자 테스트")
    func test_Profile_manager_user() throws {
        // Given
        let manager = ProfileEntity.mockManagerUser()

        // Then
        #expect(manager.role == .manager)
        #expect(manager.manger != nil)
        #expect(manager.manger?.count ?? 0 > 0)
    }

    @Test("Profile 멤버 vs 매니저 비교 테스트")
    func test_ProfileEntity_member_vs_manager() throws {
        // Given
        let member = ProfileEntity.mockMemberUser()
        let manager = ProfileEntity.mockManagerUser()

        // Then
        #expect(member.role == .member)
        #expect(manager.role == .manager)
        #expect(member.manger == nil)
        #expect(manager.manger != nil)
    }

    @Test("Profile 팀별 사용자 테스트")
    func test_Profile_team_users() throws {
        // Given
        let iosUser = ProfileEntity.mockData()
        let newGenUser = ProfileEntity.mockNewGenUser()

        // Then
        #expect(iosUser.team == .ios1)
        #expect(newGenUser.team == .ios2)
        #expect(iosUser.generation == "1기")
        #expect(newGenUser.generation == "3기")
    }

    @Test("EditProfileInput 매니저 권한 테스트")
    func test_EditProfileInput_manager_roles() throws {
        // Given
        let managerInput = EditProfileInput.mockManagerInput()

        // Then
        #expect(managerInput.managerRoles != nil)
        #expect(managerInput.managerRoles?.count ?? 0 > 0)
        #expect(managerInput.inviteCode.contains("MANAGER"))
    }
}