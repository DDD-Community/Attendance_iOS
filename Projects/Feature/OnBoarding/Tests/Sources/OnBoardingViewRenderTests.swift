//
//  OnBoardingViewRenderTests.swift
//  OnBoardingTests
//
//  온보딩 5개 화면의 body 와 @ViewBuilder 헬퍼가 실제로 평가되도록
//  상태 조합별로 렌더링한다. 크래시 없이 레이아웃이 끝나는 것이 통과 조건이다.
//

import ComposableArchitecture
import OnBoardingDomain
import ProfileDomain
import Testing

@testable import OnBoarding

@MainActor
@Suite("OnBoardingViewRendering")
struct OnBoardingViewRenderTests {
  // MARK: - InviteCode

  @Test("초대 코드 화면은 빈 입력 상태에서 렌더링된다")
  func renderInviteCodeEmpty() {
    let store = Store(initialState: InviteCodeReducer.State()) {
      InviteCodeReducer()
    } withDependencies: {
      $0.onBoardingRepository = StubOnBoardingRepository()
    }

    OnBoardingViewRenderer.render(InviteCodeView(store: store, backAction: {}))
  }

  @Test("초대 코드 화면은 네 칸이 모두 채워진 상태에서 렌더링된다")
  func renderInviteCodeFilled() {
    var state = InviteCodeReducer.State()
    state.firstInviteCode = "1"
    state.secondInviteCode = "2"
    state.thirdInviteCode = "3"
    state.lastInviteCode = "4"
    state.focusedField = .last

    let store = Store(initialState: state) {
      InviteCodeReducer()
    } withDependencies: {
      $0.onBoardingRepository = StubOnBoardingRepository()
    }

    OnBoardingViewRenderer.render(InviteCodeView(store: store, backAction: {}))
  }

  @Test("초대 코드 화면은 오류 표시 상태에서 에러 문구까지 렌더링된다")
  func renderInviteCodeInvalid() {
    var state = InviteCodeReducer.State()
    state.firstInviteCode = "9"
    state.isNotAvailableCode = true

    let store = Store(initialState: state) {
      InviteCodeReducer()
    } withDependencies: {
      $0.onBoardingRepository = StubOnBoardingRepository()
    }

    OnBoardingViewRenderer.render(InviteCodeView(store: store, backAction: {}))
  }

  // MARK: - OnBoardingName

  @Test("이름 입력 화면은 기본 상태에서 렌더링된다")
  func renderNameDefault() {
    let store = Store(initialState: OnBoardingName.State()) {
      OnBoardingName()
    }

    OnBoardingViewRenderer.render(OnBoardingNameView(store: store, backAction: {}))
  }

  @Test("이름 입력 화면은 사용 불가 상태에서 에러 문구까지 렌더링된다")
  func renderNameUnavailable() {
    var state = OnBoardingName.State()
    state.userSession.name = "홍길동"
    state.isNotAvailableName = true

    let store = Store(initialState: state) {
      OnBoardingName()
    }

    OnBoardingViewRenderer.render(OnBoardingNameView(store: store, backAction: {}))
  }

  // MARK: - SelectPart

  @Test("직무 선택 화면은 로딩 상태에서 렌더링된다")
  func renderSelectPartLoading() {
    var state = SelectPartReducer.State()
    state.loading = true

    let store = Store(initialState: state) {
      SelectPartReducer()
    } withDependencies: {
      $0.onBoardingRepository = StubOnBoardingRepository(jobs: OnBoardingCoverageFixture.jobs)
    }

    OnBoardingViewRenderer.render(SelectPartView(store: store, backAction: {}))
  }

  @Test("직무 선택 화면은 목록이 채워지고 선택된 상태에서 렌더링된다")
  func renderSelectPartLoaded() {
    var state = SelectPartReducer.State()
    state.selectJobs = .init(uniqueElements: OnBoardingCoverageFixture.jobs)
    state.selectPart = .ios
    state.activeSelectPart = true

    let store = Store(initialState: state) {
      SelectPartReducer()
    } withDependencies: {
      $0.onBoardingRepository = StubOnBoardingRepository(jobs: OnBoardingCoverageFixture.jobs)
    }

    OnBoardingViewRenderer.render(SelectPartView(store: store, backAction: {}))
  }

  // MARK: - SelectManaging

  @Test("담당 업무 선택 화면은 로딩 상태에서 렌더링된다")
  func renderSelectManagingLoading() {
    var state = SelectManagingReducer.State()
    state.loading = true

    let store = Store(initialState: state) {
      SelectManagingReducer()
    } withDependencies: {
      $0.onBoardingRepository = StubOnBoardingRepository(managings: OnBoardingCoverageFixture.managings)
    }

    OnBoardingViewRenderer.render(SelectManagingView(store: store, backAction: {}))
  }

  @Test("담당 업무 선택 화면은 운영진일 때 다음 버튼으로 렌더링된다")
  func renderSelectManagingForManager() {
    var state = SelectManagingReducer.State()
    state.selectMangers = .init(uniqueElements: OnBoardingCoverageFixture.managings)
    state.userSession.userRole = .manager
    state.activeButton = true

    let store = Store(initialState: state) {
      SelectManagingReducer()
    } withDependencies: {
      $0.onBoardingRepository = StubOnBoardingRepository(managings: OnBoardingCoverageFixture.managings)
    }

    OnBoardingViewRenderer.render(SelectManagingView(store: store, backAction: {}))
  }

  @Test("담당 업무 선택 화면은 멤버일 때 가입완료 버튼으로 렌더링된다")
  func renderSelectManagingForMember() {
    var state = SelectManagingReducer.State()
    state.selectMangers = .init(uniqueElements: OnBoardingCoverageFixture.managings)
    state.userSession.userRole = .member

    let store = Store(initialState: state) {
      SelectManagingReducer()
    } withDependencies: {
      $0.onBoardingRepository = StubOnBoardingRepository(managings: OnBoardingCoverageFixture.managings)
    }

    OnBoardingViewRenderer.render(SelectManagingView(store: store, backAction: {}))
  }

  // MARK: - SelectTeam

  @Test("팀 선택 화면은 로딩 상태에서 렌더링된다")
  func renderSelectTeamLoading() {
    var state = SelectTeam.State()
    state.loading = true

    let store = Store(initialState: state) {
      SelectTeam()
    } withDependencies: {
      $0.onBoardingRepository = StubOnBoardingRepository(teams: OnBoardingCoverageFixture.teams)
      $0.signUpUseCase = StubSignUpUseCase()
      $0.profileUseCase = StubProfileUseCase()
    }

    OnBoardingViewRenderer.render(SelectTeamView(store: store, backAction: {}))
  }

  @Test("팀 선택 화면은 목록이 채워지고 팀이 선택된 상태에서 렌더링된다")
  func renderSelectTeamLoaded() {
    var state = SelectTeam.State()
    state.teams = .init(uniqueElements: OnBoardingCoverageFixture.teams)
    state.selectTeam = .ios1
    state.activeButton = true
    state.userSession.selectTeam = .ios1

    let store = Store(initialState: state) {
      SelectTeam()
    } withDependencies: {
      $0.onBoardingRepository = StubOnBoardingRepository(teams: OnBoardingCoverageFixture.teams)
      $0.signUpUseCase = StubSignUpUseCase()
      $0.profileUseCase = StubProfileUseCase()
    }

    OnBoardingViewRenderer.render(SelectTeamView(store: store, backAction: {}))
  }

  @Test("팀 선택 화면은 실패 알럿이 떠 있는 상태에서도 렌더링된다")
  func renderSelectTeamWithAlert() {
    var state = SelectTeam.State()
    state.teams = .init(uniqueElements: OnBoardingCoverageFixture.teams)
    state.alert = AlertState {
      TextState("회원가입 실패")
    } actions: {
      ButtonState(action: .confirmTapped) {
        TextState("확인")
      }
    } message: {
      TextState("알 수 없는 오류가 발생했습니다.")
    }

    let store = Store(initialState: state) {
      SelectTeam()
    } withDependencies: {
      $0.onBoardingRepository = StubOnBoardingRepository(teams: OnBoardingCoverageFixture.teams)
      $0.signUpUseCase = StubSignUpUseCase()
      $0.profileUseCase = StubProfileUseCase()
    }

    OnBoardingViewRenderer.render(SelectTeamView(store: store, backAction: {}))
  }
}
