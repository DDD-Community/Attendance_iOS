//
//  ProfileReducerTests.swift
//  ProfileTests
//
//  Created by DDD on 2026-09-02
//  Copyright © 2026 DDD , Ltd. All rights reserved.
//

import ComposableArchitecture
import Entity
import Testing
import UseCase

@testable import Profile

@MainActor
@Suite("ProfileReducer")
struct ProfileReducerTests {
  @Test("appearModal 액션은 앱 피드백 작성 화면을 destination에 표시한다")
  func appearModalPresentsCreateAppDestination() async {
    let store = TestStore(initialState: ProfileReducer.State()) {
      ProfileReducer()
    }

    await store.send(.view(.appearModal)) {
      $0.destination = .createApp(.init())
    }
  }

  @Test("closeModal 액션은 표시 중인 destination을 닫는다")
  func closeModalDismissesDestination() async {
    var state = ProfileReducer.State()
    state.destination = .createApp(.init())

    let store = TestStore(initialState: state) {
      ProfileReducer()
    }

    await store.send(.view(.closeModal)) {
      $0.destination = nil
    }
  }

  @Test("showLogoutAlert 액션은 로그아웃 확인 팝업을 표시한다")
  func showLogoutAlertPresentsLogoutConfirmation() async {
    let store = TestStore(initialState: ProfileReducer.State()) {
      ProfileReducer()
    }

    await store.send(.view(.showLogoutAlert)) {
      $0.customAlert = .logout()
    }
  }

  @Test("fetchUserResponse 성공은 로딩을 끄고 프로필을 저장한다")
  func fetchUserSuccessStoresProfileAndStopsLoading() async {
    var state = ProfileReducer.State()
    state.isLoading = true
    let profile = Self.memberProfile

    let store = TestStore(initialState: state) {
      ProfileReducer()
    }

    await store.send(.inner(.fetchUserResponse(.success(profile)))) {
      $0.isLoading = false
      $0.profileModel = profile
    }
  }

  @Test("logoutResponses 성공은 로그아웃 결과 저장 후 로그아웃 navigation을 보낸다")
  func logoutSuccessSendsLogoutNavigation() async {
    let authExit = AuthExitEntity(code: "200", message: "ok", detail: nil)
    let store = TestStore(initialState: ProfileReducer.State()) {
      ProfileReducer()
    }

    await store.send(.inner(.logoutResponses(.success(authExit)))) {
      $0.authExit = authExit
    }
    await store.receive(\.navigation.presentLogOut)
  }

  @Test("deleteUserResponse 성공이 아니면 로그아웃 navigation을 보내지 않는다")
  func deleteUserNonSuccessDoesNotNavigate() async {
    let response = WithdrawEntity(isSuccess: false, code: "400", message: "failed")
    let store = TestStore(initialState: ProfileReducer.State()) {
      ProfileReducer()
    }

    await store.send(.inner(.deleteUserResponse(.success(response)))) {
      $0.deleteUser = response
    }
  }
}

private extension ProfileReducerTests {
  static let memberProfile = ProfileEntity(
    userID: 1,
    name: "김철수",
    generation: "2기",
    team: .ios1,
    jobRole: .ios,
    role: .member,
    manger: nil
  )
}
