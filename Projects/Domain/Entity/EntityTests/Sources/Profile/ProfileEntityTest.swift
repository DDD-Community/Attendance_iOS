//
//  ProfileEntityTest.swift
//  EntityTests
//
//  Created by TDD Automation on 2026-01-30
//

import Testing
import XCTest
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
}

class ProfileEntityXCTest: XCTestCase {
    func test_ProfileEntity_member_vs_manager() {
        // Given
        let member = ProfileEntity.mockMemberUser()
        let manager = ProfileEntity.mockManagerUser()

        // Then
        XCTAssertEqual(member.role, .member)
        XCTAssertEqual(manager.role, .manager)
        XCTAssertNil(member.manger)
        XCTAssertNotNil(manager.manger)
    }
}