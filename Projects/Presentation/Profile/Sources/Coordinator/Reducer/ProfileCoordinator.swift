//
//  ProfileCoordinator.swift
//  Profile
//
//  Created by Wonji Suh  on 1/4/26.
//


import Foundation

import Shareds

import ComposableArchitecture
import TCACoordinators

@Reducer
public struct ProfileCoordinator {
  public init() {}

  @ObservableState
  public struct State: Equatable {
    var routes: [Route<ProfileScreen.State>]

    public init() {
      routes = [.root(.profile(.init()), embedInNavigationView: true)]
    }
  }

  public enum Action: ViewAction, BindableAction, FeatureAction {
    case binding(BindingAction<State>)
    case router(IndexedRouterActionOf<ProfileScreen>)
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
    case presentLogin
    case presentRoot
  }

  @Dependency(\.continuousClock) var clock

  public var body: some ReducerOf<Self> {
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

  private func handleRouterAction(
    state: inout State,
    action: IndexedRouterActionOf<ProfileScreen>
  ) -> Effect<Action> {
    switch action {
    case .routeAction(id: _, action: .profile(.navigation(.presentLogOut))):
      return .run { send in
        await send(.navigation(.presentLogin))
      }

      case .routeAction(id: _, action: .profile(.navigation(.presentPrivacyPolicy))):
        state.routes.push(.web(.init(url: "https://dddset.notion.site/DDD-2d424441b0b08080a518ed42f1315b20?source=copy_link")))
        return .none

      case .routeAction(id: _, action: .web(.backToRoot)):
        return .send(.view(.backAction))

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
    switch action {

    }
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
    case .presentLogin:
      return .none

      case .presentRoot:
        return .none
    }
  }
}

extension ProfileCoordinator {
  @Reducer(state: .equatable)
  public enum ProfileScreen {
    case profile(ProfileReducer)
    case web(WebReducer)
  }
}
