//
//  ProfileEntityTest.swift
//  EntityTests
//
//  Created by TDD AI Automation on 2026-01-30
//

import Testing
@testable import Entity

@Suite("Profile Entity Tests - AI Generated")
struct ProfileEntityTest {

    // MARK: - 프로필 권한 시스템 테스트
    @Test("ProfileEntity 권한 계층 구조 검증")
    func test_profile_entity_authority_hierarchy() throws {
        // Given: AI가 분석한 권한 시스템
        let manager = ProfileEntity.mockManagerUser()
        let member = ProfileEntity.mockMemberUser()

        // Then: 권한 계층 구조 검증
        #expect(manager.role == .manager, "매니저 권한")
        #expect(member.role == .member, "멤버 권한")
        #expect(manager.manger != nil, "매니저는 관리 권한 보유")
        #expect(member.manger == nil, "멤버는 관리 권한 없음")
    }

    @Test("팀별 프로필 분류 체계 검증")
    func test_team_based_profile_classification() throws {
        // Given: 다양한 팀의 프로필 데이터
        let iosProfile = ProfileEntity.mockData()
        let androidProfile = ProfileEntity.mockMemberUser()
        let webProfile = ProfileEntity.mockManagerUser()

        // Then: 팀 분류 체계 검증
        #expect(iosProfile.team == .ios1, "iOS 팀 분류")
        #expect(androidProfile.team == .and1, "Android 팀 분류")
        #expect(webProfile.team == .web1, "Web 팀 분류")

        // 직무-팀 매칭 검증
        #expect(iosProfile.jobRole == .ios, "iOS 직무 매칭")
        #expect(androidProfile.jobRole == .android, "Android 직무 매칭")
        #expect(webProfile.jobRole == .frontend, "Frontend 직무 매칭")
    }

    @Test("기수별 프로필 데이터 검증")
    func test_generation_based_profile_data() throws {
        // Given: 기수별 프로필 분류
        let firstGen = ProfileEntity.mockData()
        let secondGen = ProfileEntity.mockMemberUser()
        let thirdGen = ProfileEntity.mockNewGenUser()

        // Then: 기수 체계 검증
        #expect(firstGen.generation == "1기", "1기 분류")
        #expect(secondGen.generation == "2기", "2기 분류")
        #expect(thirdGen.generation == "3기", "3기 분류")

        // 기수별 권한 패턴 검증
        #expect(firstGen.role == .manager, "1기는 주로 매니저")
        #expect(thirdGen.role == .member, "3기는 주로 멤버")
    }

    @Test("EditProfileInput 유효성 검증")
    func test_edit_profile_input_validation() throws {
        // Given: 프로필 편집 요청 시나리오
        let managerEdit = EditProfileInput.mockManagerInput()
        let memberEdit = EditProfileInput.mockMemberInput()

        // Then: 편집 요청 유효성 검증
        #expect(managerEdit.name.isEmpty == false, "이름 필수")
        #expect(managerEdit.generationId > 0, "기수 ID 양수")
        #expect(managerEdit.inviteCode.isEmpty == false, "초대 코드 필수")

        // 권한별 편집 권한 검증
        #expect(managerEdit.managerRoles != nil, "매니저는 관리 권한 설정 가능")
        #expect(memberEdit.managerRoles == nil, "멤버는 관리 권한 설정 불가")
    }

    @Test("매니저 세부 권한 검증")
    func test_manager_detailed_permissions() throws {
        // Given: 매니저 세부 권한 시나리오
        let manager = ProfileEntity.mockManagerUser()
        let managerInput = EditProfileInput.mockManagerInput()

        // Then: 세부 권한 시스템 검증
        guard let permissions = manager.manger else {
            throw "Manager permissions should exist"
        }

        #expect(permissions.contains(.attendanceCheck), "출석 체크 권한")
        #expect(permissions.contains(.photo), "사진 권한")
        #expect(permissions.contains(.snsManagement), "SNS 관리 권한")

        // 권한 조합 유효성 검증
        #expect(permissions.count > 0, "최소 하나 이상의 권한 필요")
        #expect(managerInput.managerRoles?.count ?? 0 > 0, "관리 권한 할당 필요")
    }

    @Test("프로필 데이터 일관성 검증")
    func test_profile_data_consistency() throws {
        // Given: 다양한 프로필 조합
        let profiles = [
            ProfileEntity.mockData(),
            ProfileEntity.mockMemberUser(),
            ProfileEntity.mockManagerUser(),
            ProfileEntity.mockNewGenUser()
        ]

        // Then: 데이터 일관성 검증
        for profile in profiles {
            #expect(profile.userID > 0, "User ID는 양수")
            #expect(profile.name.isEmpty == false, "이름은 필수")
            #expect(profile.generation.contains("기"), "기수 형식 검증")

            // 권한-팀-직무 일관성 검증
            if profile.role == .manager {
                #expect(profile.manger != nil, "매니저는 관리 권한 필요")
            }
        }
    }

    @Test("초대 코드 시스템 검증")
    func test_invite_code_system() throws {
        // Given: 초대 코드 시나리오
        let managerInvite = EditProfileInput.mockManagerInput()
        let memberInvite = EditProfileInput.mockMemberInput()

        // Then: 초대 코드 시스템 검증
        #expect(managerInvite.inviteCode.contains("MANAGER"), "매니저 초대 코드 식별")
        #expect(memberInvite.inviteCode.contains("MEMBER"), "멤버 초대 코드 식별")
        #expect(managerInvite.inviteCode.count >= 10, "초대 코드 최소 길이")
        #expect(memberInvite.inviteCode.count >= 10, "초대 코드 최소 길이")
    }

    @Test("프로필 권한 승급 시나리오 검증")
    func test_profile_permission_promotion_scenario() throws {
        // Given: 멤버에서 매니저로 승급 시나리오
        let currentMember = ProfileEntity.mockMemberUser()
        let promotionEdit = EditProfileInput.mockManagerInput()

        // Then: 승급 시나리오 검증
        #expect(currentMember.role == .member, "현재 멤버 권한")
        #expect(currentMember.manger == nil, "현재 관리 권한 없음")
        #expect(promotionEdit.managerRoles != nil, "승급 후 관리 권한 부여")
        #expect(promotionEdit.inviteCode.contains("MANAGER"), "매니저 권한 초대 코드")
    }
}

// MARK: - Error Extension for Testing
extension String: Error {}