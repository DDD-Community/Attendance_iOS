import Foundation
import Testing

@testable import OnBoardingDomainInterface

@Suite("OnBoarding and SignUp defaults")
struct OnBoardingSignUpCoverageTests {
  @Test("온보딩 코드별 역할과 목록을 반환하고 호출을 추적")
  func onboardingSuccessPaths() async throws {
    let repository = MockOnBoardingRepository.withDelay(0)
    #expect(try await repository.verifyCode(code: "1234").type == .member)
    #expect(try await repository.verifyCode(code: "manager").type == .manager)
    #expect(try await repository.verifyCode(code: "other").generationID == 2025)
    #expect(try await repository.fetchJobs().count == 6)
    #expect(try await repository.fetchTeams(generationId: 12).isEmpty == false)
    #expect(try await repository.fetchManaging().isEmpty == false)
    #expect(repository.getVerifyCallCount() == 3)
    #expect(repository.getLastVerifyCall() != nil)
    #expect(repository.getFetchJobsCallCount() == 1)
    #expect(repository.getLastFetchJobsCall() != nil)
    #expect(repository.getFetchTeamsCallCount() == 1)
    #expect(repository.getLastFetchTeamsCall() != nil)
    #expect(repository.getFetchManagingCallCount() == 1)
    #expect(repository.getLastFetchManagingCall() != nil)
    repository.reset()
    #expect(repository.getVerifyCallCount() == 0)
  }

  @Test("온보딩 멤버와 매니저 구성은 목록을 제한")
  func onboardingRolePaths() async throws {
    let member = MockOnBoardingRepository.memberRole()
    #expect(try await member.fetchJobs().count == 5)
    #expect(try await member.fetchManaging().isEmpty)

    let manager = MockOnBoardingRepository.managerRole()
    #expect(try await manager.verifyCode(code: "other").type == .manager)
    #expect(try await manager.fetchJobs().count == 1)
    manager.setConfiguration(.customDelay(0))
    #expect(manager.getVerifyCallCount() == 0)
  }

  @Test("온보딩 입력 및 구성 오류를 도메인 오류로 반환")
  func onboardingFailurePaths() async {
    let repository = MockOnBoardingRepository.withDelay(0)
    await #expect(throws: OnBoardingError.invalidCode) { try await repository.verifyCode(code: "") }
    await #expect(throws: OnBoardingError.verifyFailed) { try await repository.verifyCode(code: "error") }
    await #expect(throws: OnBoardingError.networkError) { try await repository.verifyCode(code: "network") }
    await #expect(throws: OnBoardingError.invalidCode) { try await repository.verifyCode(code: "invalid") }

    await #expect(throws: OnBoardingError.verifyFailed) {
      try await MockOnBoardingRepository.failure().verifyCode(code: "1234")
    }
    await #expect(throws: OnBoardingError.networkError) {
      try await MockOnBoardingRepository.networkError().fetchJobs()
    }
    #expect(OnBoardingError.from(OnBoardingError.invalidCode) == .invalidCode)
    #expect(OnBoardingError.from(CancellationError()) == .unknownError)
  }

  @Test("회원가입 성공, 입력 검증, 구성 오류")
  func signUpPaths() async throws {
    let valid = makeInput()
    let repository = MockSignUpRepository.withDelay(0)
    #expect(try await repository.registerUser(input: valid).name == "테스터")
    #expect(repository.getRegisterCallCount() == 1)
    #expect(repository.getLastCall() != nil)
    repository.reset()
    #expect(repository.getRegisterCallCount() == 0)
    repository.setConfiguration(.customDelay(0))

    await #expect(throws: SignUpError.missingRequiredField("이름")) {
      try await repository.registerUser(input: makeInput(name: ""))
    }
    await #expect(throws: SignUpError.missingRequiredField("토큰")) {
      try await repository.registerUser(input: makeInput(token: ""))
    }
    await #expect(throws: SignUpError.missingRequiredField("기수")) {
      try await repository.registerUser(input: makeInput(generationId: 0))
    }

    await #expect(throws: SignUpError.invalidInviteCode) {
      try await MockSignUpRepository.invalidInviteCode().registerUser(input: valid)
    }
    await #expect(throws: SignUpError.expiredInviteCode) {
      try await MockSignUpRepository.expiredInviteCode().registerUser(input: valid)
    }
    await #expect(throws: SignUpError.accountCreationFailed) {
      try await MockSignUpRepository.failure().registerUser(input: valid)
    }
  }

  private func makeInput(
    name: String = "테스터",
    token: String = "token",
    generationId: Int = 12
  ) -> SignUpUserInput {
    SignUpUserInput(
      name: name,
      generationId: generationId,
      jobRole: .ios,
      teamId: 1,
      managerRoles: nil,
      provider: .google,
      token: token,
      oauthRefreshToken: nil,
      invitationCode: "CODE"
    )
  }
}
