//
//  APIPathMappingTests.swift
//  APITests
//
//  Created by DDD on 9/1/26.
//

import Testing

@testable import API

@Suite("API path mapping")
struct APIPathMappingTests {
  @Test("auth domain path keeps trailing slash for child routes")
  func authDomainKeepsTrailingSlash() {
    #expect(AttendanceDomain.auth.url == "api/auth/")
  }

  @Test("admin domain path has no trailing slash before nested attendance routes")
  func adminDomainOmitsTrailingSlash() {
    #expect(AttendanceDomain.admin.url == "api/admin")
  }

  @Test("login API resolves to auth login path")
  func loginAPIResolvesToAuthLoginPath() {
    #expect(AuthAPI.login.path == "api/auth/login")
  }

  @Test("withdraw API resolves to current user path")
  func withdrawAPIResolvesToCurrentUserPath() {
    #expect(AuthAPI.withDraw.path == "api/users/me")
  }

  @Test("admin attendance count API keeps schedule id in nested path")
  func adminAttendanceCountKeepsScheduleID() {
    #expect(AttendanceAPI.adminAttendanceCount(scheduleId: 7).description == "/me/schedules/7/attendances")
  }

  @Test("session attendance API keeps schedule id and team id in nested path")
  func sessionAttendanceKeepsScheduleAndTeamID() {
    #expect(AttendanceAPI.sessionAttendances(scheduleId: 7, teamId: 2).description == "/me/schedules/7/teams/2/attendances")
  }
}
