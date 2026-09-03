//
//  ManagementScheduleReducerTests.swift
//  ManagementTests
//
//  Created by DDD on 2026-09-03.
//
//  ScheduleReducer 의 view / async / inner / delegate / binding 분기를 훑는다.
//  ScheduleReducer 는 InnerAction 과 AsyncAction 에 @CasePathable 이 없어
//  최상위 케이스 키패스(\.async, \.inner)로만 receive 한다.
//

import ComposableArchitecture
import Entity
import Testing

@testable import Management

@MainActor
@Suite("ManagementScheduleReducer")
struct ManagementScheduleReducerTests {
  /// onAppear 는 hasFetchedSchedule 가드로 중복 조회를 막는다. 두 번 보내 가드를 확인한다.
  @Test("onAppear 는 최초 1회만 스케줄을 조회한다")
  func onAppearFetchesScheduleOnlyOnce() async {
    var stub = ManagementScheduleUseCaseStub()
    stub.schedules = ManagementScheduleFixture.all

    let store = TestStore(initialState: ScheduleReducer.State()) {
      ScheduleReducer()
    } withDependencies: {
      $0.scheduleUseCase = stub
    }

    await store.send(.view(.onAppear)) {
      $0.hasFetchedSchedule = true
    }
    await store.receive(\.async) {
      $0.loading = true
    }
    await store.receive(\.inner) {
      $0.loading = false
      $0.scheduleModel = .init(uniqueElements: ManagementScheduleFixture.all)
    }

    // 두 번째 onAppear 는 가드에 걸려 어떤 이펙트도 내보내지 않는다.
    await store.send(.view(.onAppear))
  }

  /// 빈 목록도 정상 응답이다. 로딩만 내리고 목록은 비어 있어야 한다.
  @Test("빈 스케줄 응답은 로딩만 내리고 빈 목록을 유지한다")
  func emptyScheduleResponseKeepsEmptyList() async {
    let store = TestStore(initialState: ScheduleReducer.State()) {
      ScheduleReducer()
    } withDependencies: {
      $0.scheduleUseCase = ManagementScheduleUseCaseStub()
    }

    await store.send(.async(.fetchSchedule)) {
      $0.loading = true
    }
    await store.receive(\.inner) {
      $0.loading = false
    }
  }

  /// 조회 실패는 알럿 없이 로딩만 내리고 기존 목록을 그대로 둔다.
  @Test("스케줄 조회 실패는 로딩만 내리고 기존 목록을 유지한다")
  func fetchScheduleFailureKeepsPreviousList() async {
    var stub = ManagementScheduleUseCaseStub()
    stub.error = .loadFailed

    var state = ScheduleReducer.State()
    state.scheduleModel = .init(uniqueElements: [ManagementScheduleFixture.orientation])

    let store = TestStore(initialState: state) {
      ScheduleReducer()
    } withDependencies: {
      $0.scheduleUseCase = stub
    }

    await store.send(.async(.fetchSchedule)) {
      $0.loading = true
    }
    await store.receive(\.inner) {
      $0.loading = false
    }
    #expect(store.state.scheduleModel.count == 1)
  }

  @Test("stratLoading 과 stopLoading 은 로딩 플래그를 토글한다")
  func loadingActionsToggleFlag() async {
    let store = TestStore(initialState: ScheduleReducer.State()) {
      ScheduleReducer()
    }

    await store.send(.view(.stratLoading)) {
      $0.loading = true
    }
    await store.send(.view(.stopLoading)) {
      $0.loading = false
    }
  }

  @Test("바인딩 액션은 상태를 그대로 반영한다")
  func bindingActionUpdatesState() async {
    let store = TestStore(initialState: ScheduleReducer.State()) {
      ScheduleReducer()
    }

    await store.send(.binding(.set(\.loading, true))) {
      $0.loading = true
    }
  }
}
