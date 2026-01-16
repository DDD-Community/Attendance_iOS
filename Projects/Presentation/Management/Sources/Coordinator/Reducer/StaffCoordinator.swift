//
//  StaffCoordinator.swift
//  Presentation
//
//  Created by Wonji Suh on 11/4/24.
//

import Foundation
import Utill
import Profile
import ComposableArchitecture
import TCACoordinators
import LogMacro

@Reducer
public struct StaffCoordinator {
  public init() {}

  @ObservableState
  public struct State: Equatable {

    public init() {
      self.routes = [.root(.coreMember(.init()), embedInNavigationView: true)]
    }
    var routes: [Route<CoreMemberScreen.State>]
  }

  public enum Action: ViewAction, BindableAction, FeatureAction {
    case binding(BindingAction<State>)
    case router(IndexedRouterActionOf<CoreMemberScreen>)
    case view(View)
    case async(AsyncAction)
    case inner(InnerAction)
    case navigation(NavigationAction)
  }

  // MARK: - ViewAction

  @CasePathable
  public enum View {
    case backAction
    case backToRootAction
  }

  // MARK: - AsyncAction 비동기 처리 액션

  public enum AsyncAction: Equatable {
    case startNotificationListener
    case refreshTokenExpired
  }

  // MARK: - 앱내에서 사용하는 액션

  public enum InnerAction: Equatable {

  }

  // MARK: - NavigationAction

  public enum NavigationAction: Equatable {
    case presentLogin
    case presentMember
  }

  
  @Dependency(\.continuousClock) var clock

  public var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding(_):
        return .none

      case .router(let routeAction):
        return routerAction(state: &state, action: routeAction)

      case .view(let viewAction):
        return handleViewAction(state: &state, action: viewAction)

      case .async(let asyncAction):
        return handleAsyncAction(state: &state, action: asyncAction)

      case .inner(let innerAction):
        return handleInnerAction(state: &state, action: innerAction)

      case .navigation(let navigationAction):
        return handleNavigationAction(state: &state, action: navigationAction)
      }
    }
    .forEachRoute(\.routes, action: \.router)
  }

}

extension StaffCoordinator {
  private func routerAction(
    state: inout State,
    action: IndexedRouterActionOf<CoreMemberScreen>
  ) -> Effect<Action> {
    switch action {
      // MARK: - 운영진 프로필
    case .routeAction(id: _, action: .coreMember(.navigation(.presentManagerProfile))):
      state.routes.push(.profile(.init()))
      return .none


      // MARK: - 로그아웃
    case .routeAction(id: _, action: .profile(.navigation(.presentLogin))):
      return .run { send in
        try await clock.sleep(for: .seconds(0.5))
        await send(.navigation(.presentLogin))
      }

      case .routeAction(id: _, action: .profile(.navigation(.presentRoot))):
        return .send(.view(.backAction))

      case .routeAction(id: _, action: .profile(.navigation(.presentMember))):
        return .send(.navigation(.presentMember))

      case .routeAction(id: _, action: .profile(.navigation(.presentStaff))):
        return .send(.view(.backToRootAction))

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

  private func handleNavigationAction(
    state: inout State,
    action: NavigationAction
  ) -> Effect<Action> {
    switch action {
    case .presentLogin:
      return .none

      case .presentMember:
        return .none
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

  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {

  }

  /// Refresh token 만료 감지 리스너 설정
  private func setupRefreshTokenExpiredListener() -> Effect<Action> {
    #logDebug("🔔 [StaffCoordinator] Setting up RefreshTokenExpired notification listener...")
    return .publisher {
      NotificationCenter.default
        .publisher(for: NSNotification.Name("RefreshTokenExpired"))
        .map { notification in
          #logDebug("🔔 [StaffCoordinator] 🎯 RefreshTokenExpired notification received! \(notification)")
          return Action.async(.refreshTokenExpired)
        }
    }
  }
}

extension StaffCoordinator {
  @Reducer(state: .equatable)
  public enum CoreMemberScreen{
    case coreMember(Staff)
    case profile(ProfileCoordinator)
  }
}
