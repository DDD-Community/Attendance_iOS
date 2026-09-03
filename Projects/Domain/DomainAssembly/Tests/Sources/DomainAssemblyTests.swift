//
//  DomainAssemblyTests.swift
//  DomainAssemblyTests
//
//  Created by DDD on 2026-09-02
//

import Dependencies
import Testing
import AppUpdateDomain
import AttendanceDomain
import AuthDomain
import MyPageDomain
import OnBoardingDomain
import ProfileDomain
import QRCodeDomain
import ScheduleDomain
import VoteDomain

@testable import DomainAssembly

@Suite("DomainAssembly")
struct DomainAssemblyTests {
  @Test("DomainAssembly는 도메인별 UseCase 구현을 등록한다")
  func registersUseCaseDependencies() {
    withDependencies {
      DomainDependencyAssembly.register(into: &$0)
    } operation: {
      @Dependency(\.attendanceUseCase) var attendanceUseCase
      @Dependency(\.authUseCase) var authUseCase
      @Dependency(\.profileUseCase) var profileUseCase
      @Dependency(\.onBoardingUseCase) var onBoardingUseCase
      @Dependency(\.voteUseCase) var voteUseCase

      #expect(attendanceUseCase is AttendanceUseCaseImpl)
      #expect(authUseCase is AuthUseCaseImpl)
      #expect(profileUseCase is ProfileUseCaseImpl)
      #expect(onBoardingUseCase is OnBoardingUseCaseImpl)
      #expect(voteUseCase is VoteUseCaseImpl)
    }
  }

  @Test("DomainAssembly는 Entity 타입을 재수출한다")
  func reexportsEntityTypes() {
    let type = SocialType.apple

    #expect(type.description == "APPLE")
  }

  @Test("DomainAssembly는 도메인별 interface mock을 재수출한다")
  func reexportsDomainMocks() async throws {
    let repository = MockAuthRepository.success()
    let entity = try await repository.login(provider: .apple, token: "token")

    #expect(entity.provider == .apple)
  }
}
