//
//  ProfileReducerAsyncFlowTests.swift
//  ProfileTests
//
//  Created by DDD on 2026-09-03
//  Copyright © 2026 DDD , Ltd. All rights reserved.
//
//  ProfileFeature 의 비동기 이펙트(fetchUser / deleteUser / logout)와
//  destination 이 만들어내는 액션 흐름을 검증한다.
//

import Foundation
import Testing

import AuthDomainInterface
@testable import Profile
import ProfileDomainInterface

import ComposableArchitecture

@MainActor
@Suite("ProfileFeature 비동기 흐름")
struct ProfileReducerAsyncFlowTests {
  // MARK: - fetchUser

  @Test("캐시가 있으면 캐시를 먼저 표시하고 이어서 서버 갱신 결과로 덮어쓴다")
  func fetchUserWithCacheEmitsCachedThenRefreshed() async {
    let cached = ProfileTestSupport.memberProfile
    let refreshed = ProfileTestSupport.managerProfile

    let store = TestStore(initialState: ProfileFeature.State()) {
      ProfileFeature()
    } withDependencies: {
      $0.profileUseCase = StubProfileUseCase(
        cachedProfile: cached,
        getProfileResult: .success(cached),
        refreshProfileResult: .success(refreshed)
      )
    }

    await store.send(.async(.fetchUser))

    await store.receive(\.inner.fetchUserResponse) {
      $0.viewState = .loaded
      $0.profile = cached
    }

    await store.receive(\.inner.fetchUserResponse) {
      $0.profile = refreshed
    }
  }

  @Test("캐시가 있어도 서버 갱신이 실패하면 캐시 프로필이 그대로 남는다")
  func fetchUserWithCacheKeepsCachedWhenRefreshFails() async {
    let cached = ProfileTestSupport.memberProfile

    let store = TestStore(initialState: ProfileFeature.State()) {
      ProfileFeature()
    } withDependencies: {
      $0.profileUseCase = StubProfileUseCase(
        cachedProfile: cached,
        getProfileResult: .success(cached),
        refreshProfileResult: .failure(.profileNotFound)
      )
    }

    await store.send(.async(.fetchUser))

    await store.receive(\.inner.fetchUserResponse) {
      $0.viewState = .loaded
      $0.profile = cached
    }

    await store.receive(\.inner.fetchUserResponse)

    #expect(store.state.profile == cached)
  }

  @Test("캐시가 없으면 로딩을 켠 뒤 서버 조회 결과를 저장한다")
  func fetchUserWithoutCacheTurnsOnLoadingThenStoresProfile() async {
    let fetched = ProfileTestSupport.managerProfile

    let store = TestStore(initialState: ProfileFeature.State()) {
      ProfileFeature()
    } withDependencies: {
      $0.profileUseCase = StubProfileUseCase(
        cachedProfile: nil,
        getProfileResult: .success(fetched),
        refreshProfileResult: .success(fetched)
      )
    }

    await store.send(.async(.fetchUser))

    await store.receive(\.inner.fetchUserResponse) {
      $0.viewState = .loaded
      $0.profile = fetched
    }
  }

  @Test("캐시도 없고 서버 조회도 실패하면 재시도 가능한 실패 상태가 된다")
  func fetchUserFailureTurnsOffLoadingAndKeepsProfileNil() async {
    let store = TestStore(initialState: ProfileFeature.State()) {
      ProfileFeature()
    } withDependencies: {
      $0.profileUseCase = StubProfileUseCase(
        cachedProfile: nil,
        getProfileResult: .failure(.profileAccessDenied),
        refreshProfileResult: .failure(.profileAccessDenied)
      )
    }

    await store.send(.async(.fetchUser))

    await store.receive(\.inner.fetchUserResponse) {
      $0.viewState = .failed
    }

    #expect(store.state.profile == nil)
  }

  @Test("기수 변경 중에는 기존 프로필을 다시 조회하지 않는다")
  func fetchUserWhileEditingGenerationIsIgnored() async {
    let storage = InMemoryStorage()
    let initialState = withDependencies {
      $0.defaultInMemoryStorage = storage
    } operation: {
      var state = ProfileFeature.State()
      state.$editGeneration.withLock { $0 = true }
      return state
    }

    let store = TestStore(initialState: initialState) {
      ProfileFeature()
    } withDependencies: {
      $0.defaultInMemoryStorage = storage
      $0.profileUseCase = StubProfileUseCase(
        cachedProfile: nil,
        getProfileResult: .success(ProfileTestSupport.memberProfile)
      )
    }

    await store.send(.async(.fetchUser)) {
      $0.viewState = .failed
    }
    await store.finish()
  }

  @Test("이전 버전의 기수 변경 저장값이 남아도 캐시 없는 프로필을 서버에서 복구한다")
  func legacyEditFlagDoesNotBlockProfileLoading() async {
    let defaults = UserDefaults.inMemory
    defaults.set(true, forKey: "editGeneration")
    let profile = ProfileTestSupport.memberProfile
    let store = TestStore(initialState: ProfileFeature.State()) {
      ProfileFeature()
    } withDependencies: {
      $0.defaultAppStorage = defaults
      $0.defaultInMemoryStorage = InMemoryStorage()
      $0.profileUseCase = StubProfileUseCase(refreshProfileResult: .success(profile))
    }

    #expect(!store.state.editGeneration)
    await store.send(.async(.fetchUser))
    await store.receive(\.inner.fetchUserResponse) {
      $0.viewState = .loaded
      $0.profile = profile
    }
    await store.finish()
  }

  @Test("캐시가 없는 업데이트 사용자도 실패 후 재시도로 프로필을 복구한다")
  func retryAfterColdCacheFailureLoadsProfile() async {
    let store = TestStore(initialState: ProfileFeature.State()) {
      ProfileFeature()
    } withDependencies: {
      $0.profileUseCase = StubProfileUseCase()
    }

    await store.send(.async(.fetchUser))
    await store.receive(\.inner.fetchUserResponse) {
      $0.viewState = .failed
    }

    store.dependencies.profileUseCase = StubProfileUseCase(
      refreshProfileResult: .success(ProfileTestSupport.memberProfile)
    )
    await store.send(.view(.retryProfileTapped))
    await store.receive(\.async.fetchUser) {
      $0.viewState = .loading
    }
    await store.receive(\.inner.fetchUserResponse) {
      $0.viewState = .loaded
      $0.profile = ProfileTestSupport.memberProfile
    }
    await store.finish()
  }

  @Test("세션 프로필은 캐시 조회 전부터 표시하며 갱신 실패 후에도 유지한다")
  func sessionFallbackStaysVisibleDuringRefreshFailure() async {
    var state = ProfileFeature.State()
    state.$userSession.withLock {
      $0 = UserSession(userID: 7, name: "기존 사용자", generation: "1기")
    }
    let store = TestStore(initialState: state) {
      ProfileFeature()
    } withDependencies: {
      $0.profileUseCase = StubProfileUseCase()
    }
    await store.send(.async(.fetchUser)) {
      $0.viewState = .loaded
    }
    await store.receive(\.inner.fetchUserResponse)
    #expect(store.state.displayedProfile?.name == "기존 사용자")

    await store.send(.inner(.setLoading(true)))
    #expect(store.state.viewState == .loaded)
    await store.finish()
  }

  @Test("취소를 무시하고 늦게 도착한 서버 응답은 기수 변경 중 프로필을 덮어쓰지 않는다")
  func cancelledRefreshDoesNotApplyLateResponse() async {
    let started = AsyncStream<Void>.makeStream()
    let pending = LockIsolated<CheckedContinuation<ProfileEntity, Never>?>(nil)
    var useCase = StubProfileUseCase(cachedProfile: ProfileTestSupport.memberProfile)
    useCase.refreshOperation = {
      await withCheckedContinuation { continuation in
        pending.setValue(continuation)
        started.continuation.yield(())
      }
    }
    let store = TestStore(initialState: ProfileFeature.State()) {
      ProfileFeature()
    } withDependencies: {
      $0.profileUseCase = useCase
    }

    await store.send(.async(.fetchUser))
    await store.receive(\.inner.fetchUserResponse) {
      $0.viewState = .loaded
      $0.profile = ProfileTestSupport.memberProfile
    }
    var iterator = started.stream.makeAsyncIterator()
    _ = await iterator.next()

    await store.send(.delegate(.presentEditGeneration)) {
      $0.$editGeneration.withLock { $0 = true }
    }
    pending.value?.resume(returning: ProfileTestSupport.managerProfile)
    started.continuation.finish()
    await store.finish()
    #expect(store.state.profile == ProfileTestSupport.memberProfile)
  }

  // MARK: - deleteUser

  @Test("탈퇴 확인 팝업의 확인은 탈퇴 요청을 태우고 로그아웃 화면 이동을 요청한다")
  func withdrawConfirmRunsDeleteUserAndRequestsLogoutNavigation() async {
    var initialState = ProfileFeature.State()
    initialState.customAlert = .withdrawAccount()

    let store = TestStore(initialState: initialState) {
      ProfileFeature()
    } withDependencies: {
      $0.authUseCase = StubAuthRepository()
    }

    await store.send(.scope(.customAlert(.presented(.confirmTapped)))) {
      $0.customAlert = nil
    }

    await store.receive(\.async.deleteUser)

    await store.receive(\.inner.deleteUserResponse)

    await store.receive(\.delegate.presentLogOut)
  }

  @Test("탈퇴 응답이 isSuccess=false 면 화면 이동을 요청하지 않는다")
  func deleteUserRejectedDoesNotNavigate() async {
    let store = TestStore(initialState: ProfileFeature.State()) {
      ProfileFeature()
    } withDependencies: {
      $0.authUseCase = StubAuthRepository(
        withdrawResult: .success(ProfileTestSupport.withdrawRejected)
      )
    }

    await store.send(.async(.deleteUser))

    await store.receive(\.inner.deleteUserResponse)
  }

  @Test("탈퇴 요청이 실패하면 탈퇴 실패 알럿을 띄운다")
  func deleteUserFailurePresentsWithdrawFailureAlert() async {
    let error = AuthError.accountDeletionFailed

    let store = TestStore(initialState: ProfileFeature.State()) {
      ProfileFeature()
    } withDependencies: {
      $0.authUseCase = StubAuthRepository(withdrawResult: .failure(error))
    }

    await store.send(.async(.deleteUser))

    await store.receive(\.inner.deleteUserResponse) {
      $0.alert = AlertState {
        TextState("탈퇴실패")
      } actions: {
        ButtonState(action: .confirmTapped) {
          TextState("확인")
        }
      } message: {
        TextState("회원 탈퇴 실패: \(String(describing: error.errorDescription ?? error.localizedDescription))")
      }
    }
  }

  // MARK: - logout

  @Test("로그아웃 확인 팝업의 확인은 로그아웃 요청을 태우고 로그아웃 화면 이동을 요청한다")
  func logoutConfirmRunsLogoutAndRequestsLogoutNavigation() async {
    var initialState = ProfileFeature.State()
    initialState.customAlert = .logout()

    let store = TestStore(initialState: initialState) {
      ProfileFeature()
    } withDependencies: {
      $0.authUseCase = StubAuthRepository()
    }

    await store.send(.scope(.customAlert(.presented(.confirmTapped)))) {
      $0.customAlert = nil
    }

    await store.receive(\.async.logout)

    await store.receive(\.inner.logoutResponses)

    await store.receive(\.delegate.presentLogOut)
  }

  @Test("로그아웃 요청이 실패하면 로그아웃 실패 알럿을 띄운다")
  func logoutFailurePresentsLogoutFailureAlert() async {
    let error = AuthError.logoutFailed

    let store = TestStore(initialState: ProfileFeature.State()) {
      ProfileFeature()
    } withDependencies: {
      $0.authUseCase = StubAuthRepository(logoutResult: .failure(error))
    }

    await store.send(.async(.logout))

    await store.receive(\.inner.logoutResponses) {
      $0.alert = AlertState {
        TextState("로그 아웃 실패")
      } actions: {
        ButtonState(action: .confirmTapped) {
          TextState("확인")
        }
      } message: {
        TextState("로그 아웃 실패: \(String(describing: AuthError.unknownError(error.errorDescription ?? "")))")
      }
    }
  }

  // MARK: - destination

  @Test("앱 피드백 모달의 웹 이동 위임은 모달을 닫고 잠시 뒤 웹 화면 이동을 요청한다")
  func createAppPresentWebClosesModalThenRequestsFeedbackWeb() async {
    let clock = TestClock()

    var initialState = ProfileFeature.State()
    initialState.destination = .createApp(.init())

    let store = TestStore(initialState: initialState) {
      ProfileFeature()
    } withDependencies: {
      $0.continuousClock = clock
    }

    await store.send(.destination(.presented(.createApp(.delegate(.presentWeb))))) {
      $0.destination = nil
    }

    await clock.advance(by: .seconds(0.05))

    await store.receive(\.delegate.presentAppPeedBackWeb)
  }
}
