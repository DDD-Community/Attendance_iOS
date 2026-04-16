//
//  RepositoryBasicTest.swift
//  Repository
//
//  Created by Wonji Suh on 4/17/26.
//

import Testing
import Foundation
@testable import Repository

@MainActor
struct RepositoryBasicTest {

  // MARK: - Repository 기본 동작 검증

  @Test("AuthRepository가 올바르게 초기화되는지 확인")
  func testAuthRepositoryInitialization() async throws {
    // Given & When
    let repository = AuthRepositoryImpl()

    // Then
    #expect(repository != nil)
  }

  @Test("AttendanceRepository가 올바르게 초기화되는지 확인")
  func testAttendanceRepositoryInitialization() async throws {
    // Given & When
    let repository = AttendanceRepositoryImpl()

    // Then
    #expect(repository != nil)
  }

  @Test("ProfileRepository가 올바르게 초기화되는지 확인")
  func testProfileRepositoryInitialization() async throws {
    // Given & When
    let repository = ProfileRepositoryImpl()

    // Then
    #expect(repository != nil)
  }

  @Test("ScheduleRepository가 올바르게 초기화되는지 확인")
  func testScheduleRepositoryInitialization() async throws {
    // Given & When
    let repository = ScheduleRepositoryImpl()

    // Then
    #expect(repository != nil)
  }

  @Test("QRCodeRepository가 올바르게 초기화되는지 확인")
  func testQRCodeRepositoryInitialization() async throws {
    // Given & When
    let repository = QRCodeRepositoryImpl()

    // Then
    #expect(repository != nil)
  }

  @Test("MyPageRepository가 올바르게 초기화되는지 확인")
  func testMyPageRepositoryInitialization() async throws {
    // Given & When
    let repository = MyPageRepositoryImpl()

    // Then
    #expect(repository != nil)
  }

  @Test("OnBoardingRepository가 올바르게 초기화되는지 확인")
  func testOnBoardingRepositoryInitialization() async throws {
    // Given & When
    let repository = OnBoardingRepositoryImpl()

    // Then
    #expect(repository != nil)
  }

  @Test("SignUpRepository가 올바르게 초기화되는지 확인")
  func testSignUpRepositoryInitialization() async throws {
    // Given & When
    let repository = SignUpRepositoryImpl()

    // Then
    #expect(repository != nil)
  }

  @Test("GoogleOAuthRepository가 올바르게 초기화되는지 확인")
  func testGoogleOAuthRepositoryInitialization() async throws {
    // Given & When
    let repository = GoogleOAuthRepositoryImpl()

    // Then
    #expect(repository != nil)
  }

  @Test("AppUpdateRepository가 올바르게 초기화되는지 확인")
  func testAppUpdateRepositoryInitialization() async throws {
    // Given & When
    let repository = AppUpdateRepositoryImpl()

    // Then
    #expect(repository != nil)
  }
}