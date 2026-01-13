//
//  AppReducer.swift
//  DDDAttendance
//
//  Created by Wonji Suh on 10/29/24.
//

import Presentation
import ComposableArchitecture
import Entity

@Reducer
public struct AppReducer: Sendable {
  public init() {}

  @ObservableState
  public enum State {
    case splash(Splash.State)
    case auth(AuthCoordinator.State)
    case staff(StaffCoordinator.State)
    case member(MemberCoordinator.State)

    public init() {
      self = .splash(Splash.State())
    }

    // Animation identifier for SwiftUI transitions
    var animationID: String {
      switch self {
      case .splash: return "splash"
      case .auth: return "auth"
      case .staff: return "staff"
      case .member: return "member"
      }
    }
  }

  //MARK: - Action
  public enum Action: ViewAction, FeatureAction {
    case view(View)
    case async(AsyncAction)
    case inner(InnerAction)
    case navigation(NavigationAction)
    case scope(ScopeAction)
  }

  @CasePathable
  public enum View {
    case presentView
    case presentRoot
    case presentAuth
    case presentStaff
    case presentMember
  }

  //MARK: - 앱내에서 사용하는 액션
  public enum InnerAction: Equatable {

  }

  //MARK: - 비동기 처리 액션
  public enum AsyncAction: Equatable {

  }

  //MARK: - 네비게이션 연결 액션
  public enum NavigationAction: Equatable {

  }

  //MARK: - 스코프 액션
  @CasePathable
  public enum ScopeAction {
    case splash(Splash.Action)
    case auth(AuthCoordinator.Action)
    case staff(StaffCoordinator.Action)
    case member(MemberCoordinator.Action)
  }

  @Dependency(\.continuousClock) var clock

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .view(let viewAction):
        return handleViewAction(state: &state, action: viewAction)

      case .inner(let innerAction):
        return handleInnerAction(state: &state, action: innerAction)

      case .async(let asyncAction):
        return handleAsyncAction(state: &state, action: asyncAction)

      case .navigation(let navigationAction):
        return handleNavigationAction(state: &state, action: navigationAction)

      case .scope(let scopeAction):
        return handleScopeAction(state: &state, action: scopeAction)
      }
    }
    .ifCaseLet(\.splash, action: \.scope.splash) {
      Splash()
    }
    .ifCaseLet(\.auth, action: \.scope.auth) {
      AuthCoordinator()
    }
    .ifCaseLet(\.staff, action: \.scope.staff) {
      StaffCoordinator()
    }
    .ifCaseLet(\.member, action: \.scope.member) {
      MemberCoordinator()
    }
  }

  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
    case .presentView:
      return .run { send in
        await send(.scope(.splash(.view(.onAppear))))
      }

    case .presentRoot:
      // 기본적으로 멤버 화면으로 이동
      state = .member(.init())
      return .none

    case .presentAuth:
      state = .auth(.init())
      return .none

    case .presentStaff:
      state = .staff(.init())
      return .none

    case .presentMember:
      state = .member(.init())
      return .none
    }
  }

  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    return .none
  }

  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    return .none
  }

  private func handleNavigationAction(
    state: inout State,
    action: NavigationAction
  ) -> Effect<Action> {
    return .none
  }

  private func handleScopeAction(
    state: inout State,
    action: ScopeAction
  ) -> Effect<Action> {
    switch action {
    case .splash(.navigation(.presentLogin)):
      return .run { send in
        try await self.clock.sleep(for: .seconds(0.5))
        await send(.view(.presentAuth))
      }

    case .splash(.navigation(.presentStaff)):
      return .run { send in
        try await self.clock.sleep(for: .seconds(0.5))
        await send(.scope(.splash(.async(.fetchUser))))
        await send(.view(.presentStaff))
      }

    case .splash(.navigation(.presentMember)):
      return .run { send in
        try await self.clock.sleep(for: .seconds(0.5))
        await send(.scope(.splash(.async(.fetchUser))))
        await send(.view(.presentMember))
      }

    case .auth(.navigation(.presentStaff)):
      return .send(.view(.presentStaff))

    case .auth(.navigation(.presentMember)):
      return .send(.view(.presentMember))

    case .staff(.navigation(.presentLogin)):
      return .send(.view(.presentAuth))

    case .staff(.navigation(.presentMember)):
      return .send(.view(.presentMember))

    case .member(.navigation(.presentLogin)):
      return .send(.view(.presentAuth))

    case .member(.navigation(.presentStaff)):
      return .send(.view(.presentStaff))

    default:
      return .none
    }
  }
}
