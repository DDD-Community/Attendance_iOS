import Foundation
import Testing

@testable import AppUpdateDomainInterface
@testable import AttendanceDomainInterface
@testable import AuthDomainInterface
@testable import MyPageDomainInterface
@testable import OnBoardingDomainInterface
@testable import ProfileDomainInterface
@testable import QRCodeDomainInterface
@testable import ScheduleDomainInterface
@testable import VoteDomainInterface

@Suite("Domain interface mock implementations")
struct MockImplementationsCoverageTests {
  @Test("Attendance mock의 조회, 집계, 필터, 검증, 이력 분기")
  func attendanceSuccessPaths() async throws {
    let countRepository = MockAttendanceRepository.adminCountSuccess()
    #expect(try await countRepository.adminAttendanceCount(scheduleId: 1).attendanceCount == 40)
    #expect(await countRepository.getAdminCountCallCount() == 1)

    let teamsRepository = MockAttendanceRepository.teamsSuccess()
    #expect(try await teamsRepository.fetchAttendanceTeams().count == 3)

    let sessionRepository = MockAttendanceRepository.sessionAttendanceSuccess()
    #expect(try await sessionRepository.sessionAttendance(scheduleId: 3, teamId: 2).count == 5)
    #expect(await sessionRepository.getLastSessionAttendanceParams()?.scheduleId == 3)

    #expect(try await MockAttendanceRepository.statusSuccess().fetchStatus().count == 3)

    let input = EditAttendanceInput(scheduleId: 1, status: .late, userId: "10")
    #expect(try await MockAttendanceRepository.editSuccess().editAttendance(input: input).isSuccess)

    let statistics = try await MockAttendanceRepository.statisticsSuccess()
      .calculateAttendanceStatistics(startDate: .distantPast, endDate: .now)
    #expect(statistics.attendanceRate == 60)

    let filtering = MockAttendanceRepository.teamFiltering()
    let expectedCounts: [(SelectTeams, Int)] = [
      (.ios1, 8), (.ios2, 6), (.and1, 6), (.and2, 5),
      (.web1, 4), (.web2, 3), (.unknown, 0)
    ]
    for (team, count) in expectedCounts {
      #expect(try await filtering.fetchTeamAttendance(teamType: team).count == count)
    }

    let consistency = MockAttendanceRepository.consistencyValidation()
    #expect(try await consistency.validateAttendanceConsistency(scheduleId: 1, userId: 1).isValid)
    #expect(try await consistency.validateAttendanceConsistency(scheduleId: 0, userId: 0).isValid == false)

    let history = MockAttendanceRepository.historyTracking()
    #expect(try await history.getAttendanceHistory(attendanceId: 1).modificationCount == 0)
    _ = try await history.editAttendance(input: input)
    #expect(try await history.getAttendanceHistory(attendanceId: 1).modificationCount == 1)
  }

  @Test("Attendance mock의 기본값과 실패 분기")
  func attendanceFallbackAndFailurePaths() async throws {
    let fallback = MockAttendanceRepository.permissionDenied()
    #expect(try await fallback.adminAttendanceCount(scheduleId: 1).attendanceCount == 0)
    #expect(try await fallback.fetchAttendanceTeams().isEmpty)
    #expect(try await fallback.sessionAttendance(scheduleId: 1, teamId: 1).isEmpty)
    #expect(try await fallback.fetchStatus().isEmpty)
    await #expect(throws: AttendanceError.unknown) {
      try await fallback.editAttendance(input: .init(scheduleId: 1, status: .absent, userId: "1"))
    }

    let network = MockAttendanceRepository(configuration: .networkError)
    await #expect(throws: AttendanceError.unknown) { try await network.adminAttendanceCount(scheduleId: 1) }
    await #expect(throws: AttendanceError.unknown) { try await network.fetchAttendanceTeams() }
    await #expect(throws: AttendanceError.unknown) { try await network.sessionAttendance(scheduleId: 1, teamId: 1) }
    await #expect(throws: AttendanceError.unknown) { try await network.fetchStatus() }
    await #expect(throws: AttendanceError.unknown) {
      try await network.calculateAttendanceStatistics(startDate: .now, endDate: .now)
    }
    await #expect(throws: AttendanceError.unknown) { try await network.fetchTeamAttendance(teamType: .ios1) }
    await #expect(throws: AttendanceError.unknown) {
      try await network.validateAttendanceConsistency(scheduleId: 1, userId: 1)
    }
    await #expect(throws: AttendanceError.unknown) { try await network.getAttendanceHistory(attendanceId: 1) }
  }

  @Test("Auth mock의 모든 구성별 결과")
  func authPaths() async throws {
    #expect(try await MockAuthRepository.success().login(provider: .google, token: "t").name == "Google User")
    #expect(try await MockAuthRepository.appleSuccess().login(provider: .apple, token: "t").name == "Apple User")
    #expect(try await MockAuthRepository.newUser().login(provider: .google, token: "t").isNewUser)
    await #expect(throws: AuthError.invalidCredential("Mock invalid token")) {
      try await MockAuthRepository.invalidToken().login(provider: .google, token: "bad")
    }
    await #expect(throws: AuthError.unknownError("네트워크 요청에 실패했습니다")) {
      try await MockAuthRepository.networkError().login(provider: .google, token: "bad")
    }
    #expect(try await MockAuthRepository.refreshSuccess().refresh().accessToken == "new-access-token")
    await #expect(throws: AuthError.refreshTokenExpired) { try await MockAuthRepository.tokenExpired().refresh() }
    _ = try await MockAuthRepository.logoutSuccess().logout()
    await #expect(throws: AuthError.logoutFailed) { try await MockAuthRepository.serverError().logout() }
    #expect(try await MockAuthRepository.withdrawSuccess().withDraw(token: "t").isSuccess)
    await #expect(throws: AuthError.accountDeletionNotAllowed) {
      try await MockAuthRepository.unauthorized().withDraw(token: "t")
    }

    let fullFlow = MockAuthRepository.fullFlowSuccess()
    _ = try await fullFlow.login(provider: .google, token: "t")
    _ = try await fullFlow.refresh()
    _ = try await fullFlow.logout()
    let tokens = AuthTokens(accessToken: "a", refreshToken: "r")
    await fullFlow.updateSessionCredential(with: tokens)
    #expect(fullFlow.getUpdateCredentialCallCount() == 1)
    #expect(fullFlow.getLastUpdatedTokens()?.accessToken == "a")
  }

  @Test("UserSession mock의 초기 상태와 갱신 상태")
  func userSessionPaths() {
    let sessions = [
      MockUserSession.success(), .newUser(), .existingUser(),
      .appleUser(), .googleUser(), .managerUser()
    ]
    #expect(sessions.map { $0.getCurrentSession().name } == ["", "New User", "Existing User", "Apple User", "Google User", "Manager User"])

    let session = MockUserSession.existingUser()
    session.updateSession(.empty)
    session.updateStaffRole(.manager)
    session.updateOAuthRefreshToken("oauth")
    #expect(session.wasSessionUpdated())
    #expect(session.wasStaffRoleUpdated())
    #expect(session.hasOAuthRefreshToken())
    #expect(session.verifyOAuthRefreshToken("oauth"))
    #expect(session.getSessionHistory().count == 2)
    session.reset()
    #expect(session.getUpdateSessionCallCount() == 0)
  }

  @Test("Google OAuth mock의 성공, 사용자명, 실패 상태")
  func googleOAuthPaths() async throws {
    let success = MockGoogleOAuthRepository.withDelay(0)
    #expect(try await success.signIn().displayName == "Mock Google User")
    #expect(await success.getSignInCallCount() == 1)
    #expect(await success.getLastSignInCall() != nil)

    let custom = MockGoogleOAuthRepository.customUser("구글 사용자")
    #expect(try await custom.signIn().displayName == "구글 사용자")
    await custom.reset()
    #expect(await custom.getSignInCallCount() == 0)

    await #expect(throws: AuthError.invalidCredential("Mock Google OAuth sign in failed")) {
      try await MockGoogleOAuthRepository.failure().signIn()
    }
    await #expect(throws: AuthError.unknownError("Mock Google OAuth network error")) {
      try await MockGoogleOAuthRepository.networkError().signIn()
    }
  }

  @Test("Apple OAuth mock의 성공, 사용자명, 실패 상태")
  func appleOAuthPaths() async throws {
    let success = MockAppleOAuthRepository.withDelay(0)
    #expect(try await success.signIn().displayName == "Mock Apple User")
    #expect(await success.getSignInCallCount() == 1)

    let custom = MockAppleOAuthRepository.customUser("애플 사용자")
    #expect(try await custom.signIn().displayName == "애플 사용자")
    await custom.reset()
    #expect(await custom.getSignInCallCount() == 0)

    await #expect(throws: AuthError.userCancelled) { try await MockAppleOAuthRepository.userCancelled().signIn() }
    await #expect(throws: AuthError.invalidCredential("Mock Apple OAuth invalid credentials")) {
      try await MockAppleOAuthRepository(configuration: .invalidCredentials).signIn()
    }
    await #expect(throws: AuthError.unknownError("Mock Apple OAuth network error")) {
      try await MockAppleOAuthRepository.networkError().signIn()
    }
  }

}
