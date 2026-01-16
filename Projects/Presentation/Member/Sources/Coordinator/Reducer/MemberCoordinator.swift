//
//  MemberCoordinator.swift
//  Presentation
//
//  Created by 홍은표 on 1/2/25.
//

import Foundation

import Shareds

import ComposableArchitecture
import TCACoordinators
import LogMacro
import Profile

@Reducer
public struct MemberCoordinator {
  public init() {}

  @ObservableState
  public struct State: Equatable {
    var routes: [Route<MemberScreen.State>]

    public init() {
      routes = [.root(.member(.init()), embedInNavigationView: true)]
    }
  }

  public enum Action: ViewAction, BindableAction, FeatureAction {
    case binding(BindingAction<State>)
    case router(IndexedRouterActionOf<MemberScreen>)
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
    case startNotificationListener
    case refreshTokenExpired
  }

  public enum InnerAction: Equatable {
    case onResume
  }

  public enum NavigationAction: Equatable {
    case presentLogin
    case presentStaff
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

extension MemberCoordinator {
  private func handleRouterAction(
    state: inout State,
    action: IndexedRouterActionOf<MemberScreen>
  ) -> Effect<Action> {
    switch action {
    case .routeAction(id: _, action: .member(.navigation(.routeToQRCode))):
      state.routes.push(.qrCode(.init()))
      return .none

    case .routeAction(id: _, action: .member(.navigation(.routeToProfile))):
      state.routes.push(.profile(.init()))
      return .none

    case .routeAction(id: _, action: .profile(.navigation(.presentLogin))):
      return .run { send in
        try await clock.sleep(for: .seconds(0.5))
        await send(.navigation(.presentLogin))
      }

      case .routeAction(id: _, action: .profile(.navigation(.presentRoot))):
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
    case .onResume:
      return .send(
        .router(.routeAction(id: 0, action: .member(.inner(.onResume))))
      )
    }
  }

  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {
    case .startNotificationListener:
      return setupRefreshTokenExpiredListener()

    case .refreshTokenExpired:
      return .send(.navigation(.presentLogin))
    }
  }

  private func handleNavigationAction(
    state: inout State,
    action: NavigationAction
  ) -> Effect<Action> {
    switch action {
    case .presentLogin:
      return .none
      case .presentStaff:
        return .none
    }
  }

  /// Refresh token 만료 감지 리스너 설정
  private func setupRefreshTokenExpiredListener() -> Effect<Action> {
    #logDebug("🔔 [MemberCoordinator] Setting up RefreshTokenExpired notification listener...")
    return .publisher {
      NotificationCenter.default
        .publisher(for: NSNotification.Name("RefreshTokenExpired"))
        .map { notification in
          #logDebug("🔔 [MemberCoordinator] 🎯 RefreshTokenExpired notification received! \(notification)")
          return Action.async(.refreshTokenExpired)
        }
    }
  }

}

extension MemberCoordinator {
  @Reducer(state: .equatable)
  public enum MemberScreen {
    case member(MemberMain)
    case profile(ProfileCoordinator)
    case qrCode(MemberQRCode)
  }
}
