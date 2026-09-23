//
//  RequestContractTests.swift
//  APIEndpointTests
//
//  Created by DDD on 9/1/26.
//

import Foundation
import Testing

@testable import APIEndpoint

@Suite("AuthRequest")
struct AuthRequestTests {
  @Test("login uses auth login path")
  func loginUsesAuthLoginPath() {
    #expect(AuthRequest.login(body: .init(provider: "google", token: "id-token")).path == "api/auth/login")
  }

  @Test("login uses POST")
  func loginUsesPost() {
    #expect(AuthRequest.login(body: .init(provider: "google", token: "id-token")).method.rawValue == "POST")
  }

  @Test("login disables authorization pipeline")
  func loginDisablesAuthorizationPipeline() {
    #expect(AuthRequest.login(body: .init(provider: "google", token: "id-token")).authorization == .none)
  }

  @Test("login parameters include OAuth provider and token")
  func loginParametersIncludeOAuthProviderAndToken() throws {
    let parameters = AuthRequest.login(body: .init(provider: "apple", token: "id-token")).parameters
    let dictionary = try #require(try parametersDictionary(from: parameters))

    #expect(dictionary["provider"] as? String == "apple")
    #expect(dictionary["token"] as? String == "id-token")
  }

  @Test("refresh sends refresh token as parameter")
  func refreshSendsRefreshTokenParameter() throws {
    let parameters = AuthRequest.refresh(refreshToken: "refresh-token").parameters
    let dictionary = try #require(try parametersDictionary(from: parameters))

    #expect(dictionary["refreshToken"] as? String == "refresh-token")
  }

  @Test("withdraw uses automatic authorization")
  func withdrawUsesAutomaticAuthorization() {
    #expect(AuthRequest.withdraw(token: "access-token").authorization == .automatic)
  }

  @Test("logout has no parameters")
  func logoutHasNoParameters() {
    #expect(AuthRequest.logout.parameters == nil)
  }
}

@Suite("AttendanceRequest")
struct AttendanceRequestTests {
  @Test("admin attendance count uses schedule scoped admin path")
  func adminAttendanceCountUsesScheduleScopedAdminPath() {
    #expect(AttendanceRequest.adminAttendanceCount(scheduleId: 12).path == "api/admin/me/schedules/12/attendances")
  }

  @Test("fetch teams uses admin generation teams path")
  func fetchTeamsUsesAdminGenerationTeamsPath() {
    #expect(AttendanceRequest.fetchTeams.path == "api/admin/me/generations/teams")
  }

  @Test("session attendance uses schedule and team scoped admin path")
  func sessionAttendanceUsesScheduleAndTeamScopedAdminPath() {
    let body = AttendanceRequestDTO(scheduleId: 12, teamId: 3)

    #expect(AttendanceRequest.sessionAttendance(body: body).path == "api/admin/me/schedules/12/teams/3/attendances")
  }

  @Test("status uses attendance status path")
  func statusUsesAttendanceStatusPath() {
    #expect(AttendanceRequest.status.path == "api/attendances/status")
  }

  @Test("edit attendance uses PUT")
  func editAttendanceUsesPut() {
    let body = EditAttendanceRequestDTO(attendanceId: "1", status: "ATTENDANCE", userId: "user-1", scheduleId: "12")

    #expect(AttendanceRequest.editAttendance(body: body).method.rawValue == "PUT")
  }

  @Test("session attendance keeps request DTO as parameters")
  func sessionAttendanceKeepsRequestDTOAsParameters() throws {
    let parameters = AttendanceRequest.sessionAttendance(body: .init(scheduleId: 12, teamId: 3)).parameters
    let dictionary = try #require(try parametersDictionary(from: parameters))

    #expect(dictionary["scheduleId"] as? Int == 12)
    #expect(dictionary["teamId"] as? Int == 3)
  }

  @Test("admin attendance count has no parameters")
  func adminAttendanceCountHasNoParameters() {
    #expect(AttendanceRequest.adminAttendanceCount(scheduleId: 12).parameters == nil)
  }
}

private func parametersDictionary(from parameters: (any Encodable & Sendable)?) throws -> [String: Any]? {
  guard let parameters else {
    return nil
  }

  let data = try JSONEncoder().encode(AnyEncodable(parameters))
  return try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
}

private struct AnyEncodable: Encodable {
  private let encodeValue: (Encoder) throws -> Void

  init(_ value: some Encodable) {
    encodeValue = value.encode(to:)
  }

  func encode(to encoder: Encoder) throws {
    try encodeValue(encoder)
  }
}
