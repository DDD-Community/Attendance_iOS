//
//  ProfileDisplayedProfileTests.swift
//  ProfileTests
//
//  Created by DDD on 2026-09-03
//  Copyright © 2026 DDD , Ltd. All rights reserved.
//
//  ProfileReducer.State.displayedProfile 의 폴백 규칙을 고정한다.
//  UserSession 은 전역 공유 상태라 테스트끼리 간섭하지 않도록 직렬 실행하고 원복한다.
//

import ComposableArchitecture
import Entity
import Testing
import UseCase

@testable import Profile

@MainActor
@Suite("ProfileReducer.State.displayedProfile", .serialized)
struct ProfileDisplayedProfileTests {
  @Test("네트워크로 받은 프로필이 있으면 세션보다 우선한다")
  func profileModelTakesPrecedenceOverSession() {
    var state = ProfileReducer.State()
    let original = state.userSession
    defer { state.$userSession.withLock { $0 = original } }

    state.$userSession.withLock {
      $0 = UserSession(userID: 99, name: "세션이름", generation: "1기")
    }
    state.profileModel = ProfileTestSupport.managerProfile

    #expect(state.displayedProfile == ProfileTestSupport.managerProfile)
  }

  @Test("네트워크 프로필도 세션 이름도 없으면 표시할 프로필이 없다")
  func emptySessionNameYieldsNilProfile() {
    var state = ProfileReducer.State()
    let original = state.userSession
    defer { state.$userSession.withLock { $0 = original } }

    state.$userSession.withLock { $0 = .empty }

    #expect(state.displayedProfile == nil)
  }

  @Test("세션 팀이 unknown 이면 표시 프로필의 팀은 비어 있다")
  func unknownSessionTeamBecomesNilTeam() {
    var state = ProfileReducer.State()
    let original = state.userSession
    defer { state.$userSession.withLock { $0 = original } }

    state.$userSession.withLock {
      $0 = UserSession(
        userID: 11,
        name: "팀없음",
        selectPart: .backend,
        userRole: .member,
        selectTeam: .unknown,
        generation: "3기"
      )
    }

    #expect(state.displayedProfile?.team == nil)
    #expect(state.displayedProfile?.jobRole == .backend)
    #expect(state.displayedProfile?.role == .member)
  }

  @Test("세션 담당 업무가 비어 있으면 표시 프로필의 담당 업무도 비어 있다")
  func emptySessionManagingBecomesNilManger() {
    var state = ProfileReducer.State()
    let original = state.userSession
    defer { state.$userSession.withLock { $0 = original } }

    state.$userSession.withLock {
      $0 = UserSession(
        userID: 12,
        name: "담당없음",
        userRole: .manager,
        managing: [],
        selectTeam: .ios1,
        generation: "4기"
      )
    }

    #expect(state.displayedProfile?.manger == nil)
  }

  @Test("세션 담당 업무가 있으면 표시 프로필로 그대로 전달된다")
  func sessionManagingIsForwarded() {
    var state = ProfileReducer.State()
    let original = state.userSession
    defer { state.$userSession.withLock { $0 = original } }

    state.$userSession.withLock {
      $0 = UserSession(
        userID: 13,
        name: "담당있음",
        userRole: .manager,
        managing: [.photo, .snsManagement],
        selectTeam: .web1,
        generation: "5기"
      )
    }

    #expect(state.displayedProfile?.manger == [.photo, .snsManagement])
    #expect(state.displayedProfile?.team == .web1)
    #expect(state.displayedProfile?.generation == "5기")
  }
}
