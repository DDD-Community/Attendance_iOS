//
//  APIExhaustiveMappingTests.swift
//  APITests
//
//  Created by DDD on 9/4/26.
//

import Foundation
import Testing

@testable import API

@Suite("API exhaustive path mapping")
struct APIExhaustiveMappingTests {
  @Test("모든 API 도메인은 고정된 base path를 반환한다")
  func mapsEveryDomain() {
    let mappings: [(AttendanceDomain, String)] = [
      (.auth, "api/auth/"),
      (.onboarding, "api/onboarding/"),
      (.user, "api/users"),
      (.admin, "api/admin"),
      (.me, "api/me"),
      (.qr, "api/users"),
      (.schedule, "api/schedules"),
      (.attendance, "api/attendances"),
      (.myPage, "api/me"),
      (.vote, "api/votes")
    ]

    for (domain, expected) in mappings {
      #expect(domain.url == expected)
    }
  }

  @Test("모든 인증 API가 endpoint path를 반환한다")
  func mapsEveryAuthAPI() {
    #expect(AuthAPI.login.path == "api/auth/login")
    #expect(AuthAPI.refresh.path == "api/auth/refresh")
    #expect(AuthAPI.withDraw.path == "api/users/me")
    #expect(AuthAPI.logout.path == "api/auth/logout")
    #expect(AuthAPI.allCases.count == 4)
  }

  @Test("모든 출석 API가 endpoint suffix를 반환한다")
  func mapsEveryAttendanceAPI() {
    #expect(AttendanceAPI.adminAttendanceCount(scheduleId: 31).description == "/me/schedules/31/attendances")
    #expect(AttendanceAPI.fetchTeams.description == "/me/generations/teams")
    #expect(AttendanceAPI.sessionAttendances(scheduleId: 31, teamId: 7).description == "/me/schedules/31/teams/7/attendances")
    #expect(AttendanceAPI.status.description == "/status")
    #expect(AttendanceAPI.editAttendance.description.isEmpty)
  }

  @Test("모든 온보딩 API가 endpoint suffix를 반환한다")
  func mapsEveryOnBoardingAPI() {
    #expect(OnBoardingAPI.verifyCode.description == "verify-code")
    #expect(OnBoardingAPI.teams.description == "teams")
    #expect(OnBoardingAPI.jobs.description == "jobs")
    #expect(OnBoardingAPI.mangerRole.description == "manager-roles")
    #expect(OnBoardingAPI.allCases.count == 4)
  }

  @Test("프로필과 마이페이지 API의 모든 path를 반환한다")
  func mapsProfileAndMyPageAPIs() {
    #expect(ProfileAPI.getUser.profileDescription.isEmpty)
    #expect(ProfileAPI.getAdmin.profileDescription == "/me")
    #expect(ProfileAPI.editUser.profileDescription == "/me")
    #expect(ProfileAPI.allCases.count == 3)
    #expect(MyPageAPI.fetchAttendances.urlPath == "/attendances")
    #expect(MyPageAPI.fetchSchedules.urlPath == "/schedules")
  }

  @Test("단일 경로 API가 빈 suffix를 반환한다")
  func mapsSinglePathAPIs() {
    #expect(QRAPI.validate.description.isEmpty)
    #expect(ScheduleAPI.schedule.description.isEmpty)
    #expect(SignUpAPI.signUpUser.signUpDescription.isEmpty)
    #expect(ScheduleAPI.allCases == [.schedule])
    #expect(SignUpAPI.allCases == [.signUpUser])
  }

  @Test("모든 투표 API가 vote ID를 포함한 suffix를 반환한다")
  func mapsEveryVoteAPI() {
    let mappings: [(VoteAPI, String)] = [
      (.list, ""),
      (.create, ""),
      (.detail(voteId: 8), "/8"),
      (.participation(voteId: 8), "/8/participation"),
      (.nonResponders(voteId: 8), "/8/non-responders"),
      (.open(voteId: 8), "/8/open"),
      (.close(voteId: 8), "/8/close"),
      (.teamVoteResults(voteId: 8), "/8/team-vote/results"),
      (.feedbackResults(voteId: 8), "/8/feedback/results"),
      (.active, "/active"),
      (.teamVoteTemplate(voteId: 8), "/8/team-vote/template"),
      (.feedbackTemplate(voteId: 8), "/8/feedback/template"),
      (.submit(voteId: 8), "/8/responses"),
      (.myResponse(voteId: 8), "/8/responses/me")
    ]

    for (api, expected) in mappings {
      #expect(api.description == expected)
    }
  }

  @Test("base API는 HTTPS URL을 구성한다")
  func buildsBaseURL() {
    #expect(BaseAPI.base.apiDescription.hasPrefix("https://"))
  }
}
