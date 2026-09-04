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
import Testing

@testable import Management

@MainActor
@Suite("ManagementScheduleReducer")
struct ManagementScheduleReducerTests {
  /// hasFetchedSchedule 는 스켈레톤을 첫 진입으로 제한할 뿐, 재조회까지 막지는 않는다.
  @Test("onAppear 는 최초 1회만 스켈레톤을 띄우고 이후에는 조용히 갱신한다")
  func onAppearShowsSkeletonOnlyOnFirstLoad() async {
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
      $0.viewState = .loading
    }
    await store.receive(\.inner) {
      $0.viewState = .loaded
      $0.scheduleModel = .init(uniqueElements: ManagementScheduleFixture.all)
    }

    // 두 번째 onAppear 는 loading 을 건드리지 않고 목록만 다시 받아온다.
    await store.send(.view(.onAppear))
    await store.receive(\.async.refreshSchedule)
    await store.receive(\.inner)
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
      $0.viewState = .loading
    }
    await store.receive(\.inner) {
      $0.viewState = .loaded
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
      $0.viewState = .loading
    }
    await store.receive(\.inner) {
      $0.viewState = .loaded
    }
    #expect(store.state.scheduleModel.count == 1)
  }

  @Test("stratLoading 과 stopLoading 은 로딩 플래그를 토글한다")
  func loadingActionsToggleFlag() async {
    let store = TestStore(initialState: ScheduleReducer.State()) {
      ScheduleReducer()
    }

    await store.send(.view(.stratLoading)) {
      $0.viewState = .loading
    }
    await store.send(.view(.stopLoading)) {
      $0.viewState = .loaded
    }
  }

  @Test("바인딩 액션은 상태를 그대로 반영한다")
  func bindingActionUpdatesState() async {
    let store = TestStore(initialState: ScheduleReducer.State()) {
      ScheduleReducer()
    }

    await store.send(.binding(.set(\.hasFetchedSchedule, true))) {
      $0.hasFetchedSchedule = true
    }
  }
}
