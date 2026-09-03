//
//  SelectPartReducerTests.swift
//  OnBoardingTests
//
//  SelectPartReducer 의 선택/해제, 직무 목록 조회, 다음 단계 분기를 검증한다.
//

import ComposableArchitecture
import DomainInterface
import Entity
import Testing

@testable import OnBoarding

@MainActor
@Suite("SelectPartReducer")
struct SelectPartReducerTests {
  @Test("직무를 선택하면 세션에 반영되고 다음 버튼이 활성화된다")
  func selectPartButtonSelectsJob() async {
    let store = TestStore(initialState: SelectPartReducer.State()) {
      SelectPartReducer()
    }

    await store.send(.view(.selectPartButton(selectPart: OnBoardingCoverageFixture.iosJob))) {
      $0.selectPart = .ios
      $0.activeSelectPart = true
      $0.userSession.selectPart = .ios
    }
  }

  @Test("같은 직무를 다시 선택하면 선택이 해제되고 세션이 전체로 되돌아간다")
  func reselectingSameJobClearsSelection() async {
    var state = SelectPartReducer.State()
    state.selectPart = .ios
    state.activeSelectPart = true
    state.userSession.selectPart = .ios

    let store = TestStore(initialState: state) {
      SelectPartReducer()
    }

    await store.send(.view(.selectPartButton(selectPart: OnBoardingCoverageFixture.iosJob))) {
      $0.selectPart = nil
      $0.activeSelectPart = false
      $0.userSession.selectPart = .all
    }
  }

  @Test("초기 상태(.all)에서 다른 직무를 고르면 곧바로 선택된다")
  func selectingDifferentJobFromDefault() async {
    let store = TestStore(initialState: SelectPartReducer.State()) {
      SelectPartReducer()
    }

    await store.send(.view(.selectPartButton(selectPart: OnBoardingCoverageFixture.backendJob))) {
      $0.selectPart = .backend
      $0.activeSelectPart = true
      $0.userSession.selectPart = .backend
    }
  }

  @Test("onAppear 는 직무 목록을 조회해 상태에 채운다")
  func onAppearFetchesJobList() async {
    let store = TestStore(initialState: SelectPartReducer.State()) {
      SelectPartReducer()
    } withDependencies: {
      $0.onBoardingRepository = StubOnBoardingRepository(jobs: OnBoardingCoverageFixture.jobs)
    }

    await store.send(.view(.onAppear))
    await store.receive(\.async) {
      $0.loading = true
    }
    await store.receive(\.inner) {
      $0.loading = false
      $0.selectJobs = .init(uniqueElements: OnBoardingCoverageFixture.jobs)
    }
  }

  @Test("직무 목록 조회 실패는 에러 메시지를 남긴다")
  func jobListFailureStoresErrorMessage() async {
    let store = TestStore(initialState: SelectPartReducer.State()) {
      SelectPartReducer()
    } withDependencies: {
      $0.onBoardingRepository = StubOnBoardingRepository(failure: .networkError)
    }

    let expected = SignUpError.from(OnBoardingError.networkError)

    await store.send(.view(.onAppear))
    await store.receive(\.async) {
      $0.loading = true
    }
    await store.receive(\.inner) {
      $0.errorMessage = expected.errorDescription
    }
  }

  @Test("운영진이면 다음 단계에서 담당 업무 선택으로 이동한다")
  func nextStepForManagerGoesToManaging() async {
    var state = SelectPartReducer.State()
    state.userSession.userRole = .manager

    let store = TestStore(initialState: state) {
      SelectPartReducer()
    }

    await store.send(.delegate(.presentNextStep))
    await store.receive(\.delegate.presentManaging)
  }

  @Test("멤버면 다음 단계에서 팀 선택으로 이동한다")
  func nextStepForMemberGoesToSelectTeam() async {
    var state = SelectPartReducer.State()
    state.userSession.userRole = .member

    let store = TestStore(initialState: state) {
      SelectPartReducer()
    }

    await store.send(.delegate(.presentNextStep))
    await store.receive(\.delegate.presentSelectTeam)
  }

  @Test("binding 액션은 상태만 갱신한다")
  func bindingUpdatesStateOnly() async {
    let store = TestStore(initialState: SelectPartReducer.State()) {
      SelectPartReducer()
    }

    await store.send(.binding(.set(\.loading, true))) {
      $0.loading = true
    }
  }
}
