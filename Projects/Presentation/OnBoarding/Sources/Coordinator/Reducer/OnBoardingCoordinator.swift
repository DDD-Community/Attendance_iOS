//
//  OnBoardingCoordinator.swift
//  OnBoarding
//
//  Created by Wonji Suh  on 1/6/26.
//

import Foundation

import Shareds

import ComposableArchitecture
import TCACoordinators

@Reducer
public struct OnBoardingCoordinator {
  public init() {}

  @ObservableState
  public struct State: Equatable {
    var routes: [Route<OnBoardingScreen.State>]

    public init() {
      routes = [.root(.InviteCode(.init()), embedInNavigationView: true)]
    }
  }

  public enum Action: ViewAction, BindableAction, FeatureAction {
    case binding(BindingAction<State>)
    case router(IndexedRouterActionOf<OnBoardingScreen>)
    case view(View)
    case inner(InnerAction)
    case async(AsyncAction)
    case navigation(NavigationAction)
  }

  @CasePathable
  public enum View {
    case backAction
    case backToRootAction
  }

  public enum AsyncAction: Equatable {

  }

  public enum InnerAction: Equatable {

  }

  public enum NavigationAction: Equatable {
    case backToRoot
    case presentLogin
    case presentStaff
    case presentMember
    case presentProfile
  }

  @Dependency(\.continuousClock) var clock

  public var body: some Reducer<State, Action> {
    BindingReducer()

    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case .router(let action):
        return handleRouterAction(state: &state, action: action)

      case .view(let action):
        return handleViewAction(state: &state, action: action)

      case .inner(let action):
        return handleInnerAction(state: &state, action: action)

      case .async(let action):
        return handleAsyncAction(state: &state, action: action)

      case .navigation(let action):
        return handleNavigationAction(state: &state, action: action)
      }
    }
    .forEachRoute(\.routes, action: \.router)
  }
}

extension OnBoardingCoordinator {
  private func handleRouterAction(
    state: inout State,
    action: IndexedRouterActionOf<OnBoardingScreen>
  ) -> Effect<Action> {
    switch action {
        // MARK: - 이름 입력
      case .routeAction(id: _, action: .InviteCode(.navigation(.presentSignUpName))):
        state.routes.push(.onBoardingName(.init()))
        return .none

      case .routeAction(id: _, action: .onBoardingName(.navigation(.presentSignUpPart))):
        state.routes.push(.selectPart(.init()))
        return .none

        // MARK: - 운영진 담당업무 선택

      case .routeAction(id: _, action: .selectPart(.navigation(.presentManaging))):
        state.routes.push(.selectManaging(.init()))
        return .none

        // MARK: -  운영진 매니징 업무선택시  팀매니징 선택시 팀선택
      case .routeAction(id: _, action: .selectManaging(.navigation(.presentSelectTeam))):
        state.routes.push(.selectTeam(.init()))
        return .none

      case .routeAction(id: _, action: .selectManaging(.navigation(.presentCoreMember))):
        return .send(.navigation(.presentStaff))

      case .routeAction(id: _, action: .selectTeam(.navigation(.presentManager))):
        return .send(.navigation(.presentStaff))

        // MARK: - 멤버 선택 할팀 선택
      case .routeAction(id: _, action: .selectPart(.navigation(.presentSelectTeam))):
        state.routes.push(.selectTeam(.init()))
        return .none

      case .routeAction(id: _, action: .selectTeam(.navigation(.presentMember))):
        return .send(.navigation(.presentMember))

      case .routeAction(id: _, action: .selectTeam(.navigation(.presentLogin))):
        return .send(.navigation(.presentLogin))

      case .routeAction(id: _, action: .selectTeam(.navigation(.presentProfile))):
        return .send(.navigation(.presentProfile))

    default:
      return .none
    }
  }

  private func handleViewAction(
      state: inout State,
      action: View
  ) -> Effect<Action> {
    switch action {
    case .backAction:
      state.routes.goBack()
      return .none

    case .backToRootAction:
      return .routeWithDelaysIfUnsupported(state.routes, action: \.router) {
        $0.goBackToRoot()
      }
    }
  }

  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {

  }

  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {

  }

  private func handleNavigationAction(
    state: inout State,
    action: NavigationAction
  ) -> Effect<Action> {
    switch action {
    case .presentStaff:
      return .none

      case .presentMember:
        return .none

      case .presentLogin:
        return .none

      case .backToRoot:
        return .none

      case .presentProfile:
        return .none
    }
  }
}

extension OnBoardingCoordinator {
  @Reducer(state: .equatable)
  public enum OnBoardingScreen {
    case InviteCode(InviteCodeReducer)
    case onBoardingName(OnBoardingName)
    case selectPart(SelectPartReducer)
    case selectManaging(SelectManagingReducer)
    case selectTeam(SelectTeam)
  }
}
