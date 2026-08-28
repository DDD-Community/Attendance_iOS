//
//  MemberCoordinator.swift
//  Presentation
//
//  Created by 홍은표 on 1/2/25.
//

import Foundation

import DDDSharedUI

import ComposableArchitecture
import TCAFlow
import LogMacro
import Profile

@FlowCoordinator(screen: "MemberScreen", navigation: true)
public struct MemberCoordinator {
  public init() {}

  @ObservableState
  public struct State: Equatable {
    var routes: [Route<MemberScreen.State>]

    public init() {
      routes = [.root(.member(.init()), embedInNavigationView: true)]
    }
  }

  @CasePathable
  public enum Action {
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
    // RefreshTokenExpired는 AppReducer에서 처리하므로 중복 제거
  }

  public enum InnerAction: Equatable {
    case onResume
  }

  public enum NavigationAction: Equatable {
    case presentLogin
    case presentStaff
  }

  @Dependency(\.continuousClock) var clock

  public nonisolated enum CancelID: Hashable, Sendable {
    case allEffects
    case profileEffects
  }

  func handleRoute(state: inout State, action: Action) -> Effect<Action> {
    switch action {
      case .router(let action):
        return routerAction(state: &state, action: action)

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
}

extension MemberCoordinator {
  private func routerAction(
    state: inout State,
    action: IndexedRouterActionOf<MemberScreen>
  ) -> Effect<Action> {
    switch action {
    case .routeAction(id: _, action: .member(.navigation(.routeToQRCode))):
      state.routes.push(.qrCode(.init()))
      return .none

    case .routeAction(id: _, action: .member(.navigation(.routeToProfile))):
      state.routes.push(.profile(.init()))
      return .concatenate(
        .cancel(id: CancelID.profileEffects),
        .cancel(id: ProfileReducer.CancelID.fetchProfile),
        .cancel(id: ProfileReducer.CancelID.deleteUser),
        .cancel(id: ProfileReducer.CancelID.logoutUser)
      )

    case .routeAction(id: _, action: .profile(.navigation(.presentLogin))):
      state.routes.goBackToRoot()
      return .concatenate(
        .cancel(id: CancelID.allEffects),
        .cancel(id: CancelID.profileEffects),
        .cancel(id: ProfileReducer.CancelID.fetchProfile),
        .cancel(id: ProfileReducer.CancelID.deleteUser),
        .cancel(id: ProfileReducer.CancelID.logoutUser),
        .run { send in
          await Task.yield()
          await send(.navigation(.presentLogin))
        }
      )
      .cancellable(id: CancelID.allEffects, cancelInFlight: true)

      // 기수변경으로 멤버 → 운영진이 된 경우 운영진 홈으로 전환
      case .routeAction(id: _, action: .profile(.navigation(.presentStaff))):
        return .send(.navigation(.presentStaff))

      case .routeAction(id: _, action: .profile(.navigation(.presentRoot))):
        return .concatenate(
          .cancel(id: CancelID.profileEffects),
          .cancel(id: ProfileReducer.CancelID.fetchProfile),
          .cancel(id: ProfileReducer.CancelID.deleteUser),
          .cancel(id: ProfileReducer.CancelID.logoutUser),
          .send(.view(.backAction))
        )

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
      state.routes.goBackToRoot()
      return .none
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
    // RefreshTokenExpired는 AppReducer에서 처리하므로 여기서는 처리할 액션이 없음
    return .none
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

  // RefreshTokenExpired listener는 AppReducer에서 처리하므로 중복 제거

}

extension MemberCoordinator {
  @Reducer
  public enum MemberScreen {
    case member(MemberMain)
    case profile(ProfileCoordinator)
    case qrCode(MemberQRCode)
  }
}

extension MemberCoordinator.MemberScreen.State: Equatable {}
