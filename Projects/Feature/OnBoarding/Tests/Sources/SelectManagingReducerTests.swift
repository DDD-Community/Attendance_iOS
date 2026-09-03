//
//  SelectManagingReducerTests.swift
//  OnBoardingTests
//
//  SelectManagingReducer 의 담당 업무 토글, 목록 조회, 가입/기수변경 분기를 검증한다.
//

import ComposableArchitecture
import DomainInterface
import Entity
import Testing
import UseCase

@testable import OnBoarding

@MainActor
@Suite("SelectManagingReducer")
struct SelectManagingReducerTests {
  // MARK: - ViewAction

  @Test("목록이 비어 있으면 onAppear 가 담당 업무 목록을 조회한다")
  func onAppearFetchesManagingList() async {
    let store = TestStore(initialState: SelectManagingReducer.State()) {
      SelectManagingReducer()
    } withDependencies: {
      $0.onBoardingRepository = StubOnBoardingRepository(managings: OnBoardingCoverageFixture.managings)
    }

    await store.send(.view(.onAppear))
    await store.receive(\.async) {
      $0.loading = true
    }
    await store.receive(\.inner) {
      $0.loading = false
      $0.selectMangers = .init(uniqueElements: OnBoardingCoverageFixture.managings)
    }
  }

  @Test("목록이 이미 있으면 onAppear 는 다시 조회하지 않는다")
  func onAppearSkipsFetchWhenListAlreadyLoaded() async {
    var state = SelectManagingReducer.State()
    state.selectMangers = .init(uniqueElements: OnBoardingCoverageFixture.managings)

    let store = TestStore(initialState: state) {
      SelectManagingReducer()
    }

    await store.send(.view(.onAppear))
  }

  @Test("담당 업무 목록 조회 실패는 에러 메시지를 남긴다")
  func managingListFailureStoresErrorMessage() async {
    let store = TestStore(initialState: SelectManagingReducer.State()) {
      SelectManagingReducer()
    } withDependencies: {
      $0.onBoardingRepository = StubOnBoardingRepository(failure: .verifyFailed)
    }

    let expected = SignUpError.from(OnBoardingError.verifyFailed)

    await store.send(.view(.onAppear))
    await store.receive(\.async) {
      $0.loading = true
    }
    await store.receive(\.inner) {
      $0.errorMessage = expected.errorDescription
    }
  }

  @Test("담당 업무를 처음 누르면 세션에 추가되고 버튼이 활성화된다")
  func selectManagingButtonAppendsManaging() async {
    let store = TestStore(initialState: SelectManagingReducer.State()) {
      SelectManagingReducer()
    }

    await store.send(.view(.selectManagingButton(selectManaging: OnBoardingCoverageFixture.photoManaging))) {
      $0.userSession.managing = [.photo]
      $0.activeButton = true
    }
  }

  @Test("이미 선택된 담당 업무를 다시 누르면 제거되고 버튼이 비활성화된다")
  func selectManagingButtonRemovesManaging() async {
    var state = SelectManagingReducer.State()
    state.userSession.managing = [.photo]
    state.activeButton = true

    let store = TestStore(initialState: state) {
      SelectManagingReducer()
    }

    await store.send(.view(.selectManagingButton(selectManaging: OnBoardingCoverageFixture.photoManaging))) {
      $0.userSession.managing = []
      $0.activeButton = false
    }
  }

  // MARK: - 회원가입 / 기수 변경

  @Test("가입 완료는 회원가입을 호출하고 운영진 홈으로 이동한다")
  func signUpNavigatesToManager() async {
    var state = SelectManagingReducer.State()
    state.editGeneration = false
    state.userSession.userRole = .manager

    let store = TestStore(initialState: state) {
      SelectManagingReducer()
    } withDependencies: {
      $0.signUpUseCase = StubSignUpUseCase()
    }

    await store.send(.view(.signUp))
    await store.receive(\.async)
    await store.receive(\.inner) {
      $0.signUpUser = OnBoardingCoverageFixture.signUpUser
      $0.staffRole = .manager
    }
    await store.receive(\.delegate.presentManager)
  }

  @Test("회원가입 실패는 에러 메시지와 실패 알럿을 표시한다")
  func signUpFailurePresentsAlert() async {
    let store = TestStore(initialState: SelectManagingReducer.State()) {
      SelectManagingReducer()
    } withDependencies: {
      $0.signUpUseCase = StubSignUpUseCase(failure: .accountCreationFailed)
    }

    let error = SignUpError.accountCreationFailed

    await store.send(.view(.signUp))
    await store.receive(\.async)
    await store.receive(\.inner) {
      $0.errorMessage = error.errorDescription
      $0.alert = AlertState {
        TextState("회원가입 실패")
      } actions: {
        ButtonState(action: .confirmTapped) {
          TextState("확인")
        }
      } message: {
        TextState(error.errorDescription ?? "알 수 없는 오류가 발생했습니다.")
      }
    }
  }

  @Test("기수 변경 중이면 가입 완료가 프로필 수정을 호출하고 멤버 홈으로 이동한다")
  func editGenerationNavigatesToMember() async {
    var state = SelectManagingReducer.State()
    state.editGeneration = true

    let profile = OnBoardingCoverageFixture.memberProfile

    let store = TestStore(initialState: state) {
      SelectManagingReducer()
    } withDependencies: {
      $0.profileUseCase = StubProfileUseCase(profile: profile)
    }

    await store.send(.view(.signUp))
    await store.receive(\.async)
    await store.receive(\.inner) {
      $0.editProfile = profile
      $0.editGeneration = false
      $0.staffRole = .member
      $0.userSession.userID = profile.userID
      $0.userSession.name = profile.name
      $0.userSession.generation = profile.generation
      $0.userSession.selectTeam = .web1
      $0.userSession.selectPart = profile.jobRole
      $0.userSession.userRole = .member
      $0.userSession.managing = []
    }
    await store.receive(\.delegate.presentMember)
  }

  @Test("프로필 수정 결과가 운영진이면 운영진 홈으로 이동한다")
  func editProfileManagerNavigatesToManager() async {
    var state = SelectManagingReducer.State()
    state.editGeneration = true

    let profile = OnBoardingCoverageFixture.managerProfile

    let store = TestStore(initialState: state) {
      SelectManagingReducer()
    }

    await store.send(.inner(.editProfileResponse(.success(profile)))) {
      $0.editProfile = profile
      $0.editGeneration = false
      $0.staffRole = .manager
      $0.userSession.userID = profile.userID
      $0.userSession.name = profile.name
      $0.userSession.generation = profile.generation
      $0.userSession.selectTeam = .ios1
      $0.userSession.selectPart = profile.jobRole
      $0.userSession.userRole = .manager
      $0.userSession.managing = [.teamManaging]
    }
    await store.receive(\.delegate.presentManager)
  }

  @Test("프로필 수정 실패는 기수 변경 플래그를 내리고 실패 알럿을 표시한다")
  func editProfileFailurePresentsAlert() async {
    var state = SelectManagingReducer.State()
    state.editGeneration = true

    let store = TestStore(initialState: state) {
      SelectManagingReducer()
    }

    let error = ProfileError.profileNotFound

    await store.send(.inner(.editProfileResponse(.failure(error)))) {
      $0.errorMessage = error.errorDescription
      $0.editGeneration = false
      $0.alert = AlertState {
        TextState("프로필 수정 실패")
      } actions: {
        ButtonState(action: .confirmTapped) {
          TextState("확인")
        }
      } message: {
        TextState(error.errorDescription ?? "알 수 없는 오류가 발생했습니다.")
      }
    }
  }

  // MARK: - Delegate / Scope / Binding

  @Test("delegate 액션은 모두 부수효과 없이 소비된다")
  func delegateActionsProduceNoEffect() async {
    let store = TestStore(initialState: SelectManagingReducer.State()) {
      SelectManagingReducer()
    }

    await store.send(.delegate(.presentManager))
    await store.send(.delegate(.presentMember))
    await store.send(.delegate(.presentSelectTeam))
    await store.send(.delegate(.presentProfile))
  }

  @Test("알럿을 닫으면 alert 상태가 비워진다")
  func dismissingAlertClearsState() async {
    var state = SelectManagingReducer.State()
    state.alert = AlertState {
      TextState("회원가입 실패")
    } actions: {
      ButtonState(action: .confirmTapped) {
        TextState("확인")
      }
    }

    let store = TestStore(initialState: state) {
      SelectManagingReducer()
    }

    await store.send(.scope(.alert(.dismiss))) {
      $0.alert = nil
    }
  }

  @Test("binding 액션은 상태만 갱신한다")
  func bindingUpdatesStateOnly() async {
    let store = TestStore(initialState: SelectManagingReducer.State()) {
      SelectManagingReducer()
    }

    await store.send(.binding(.set(\.activeButton, true))) {
      $0.activeButton = true
    }
  }
}
