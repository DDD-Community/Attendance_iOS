//
//  AppReducer.swift
//  DDDAttendance
//
//  Created by Wonji Suh on 10/29/24.
//

import Presentation
import ComposableArchitecture
import Entity
import LogMacro
import Profile

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
    case startNotificationListener
    case refreshTokenExpired
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

  private enum CancelID {
    case refreshTokenExpiredListener
    case splashRouting
    case authEffects
    case staffEffects
    case memberEffects
  }

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
      return .concatenate(
        .cancel(id: CancelID.staffEffects),
        .cancel(id: CancelID.memberEffects),
        .cancel(id: ProfileReducer.CancelID.fetchProfile),
        .cancel(id: ProfileReducer.CancelID.deleteUser),
        .cancel(id: ProfileReducer.CancelID.logoutUser)
      )

    case .presentStaff:
      state = .staff(.init())
      return .concatenate(
        .cancel(id: CancelID.authEffects),
        .cancel(id: CancelID.memberEffects),
        .cancel(id: ProfileReducer.CancelID.fetchProfile),
        .cancel(id: ProfileReducer.CancelID.deleteUser),
        .cancel(id: ProfileReducer.CancelID.logoutUser)
      )

    case .presentMember:
      state = .member(.init())
      return .concatenate(
        .cancel(id: CancelID.authEffects),
        .cancel(id: CancelID.staffEffects),
        .cancel(id: ProfileReducer.CancelID.fetchProfile),
        .cancel(id: ProfileReducer.CancelID.deleteUser),
        .cancel(id: ProfileReducer.CancelID.logoutUser)
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
        .cancellable(id: CancelID.refreshTokenExpiredListener, cancelInFlight: true)

    case .refreshTokenExpired:
      // Refresh token이 만료된 경우 로그인 화면으로 이동
        #logDebug("🚪 [AppReducer] 🔥 REFRESH TOKEN EXPIRED - REDIRECTING TO LOGIN!")
      state = .auth(.init())
        #logDebug("✅ [AppReducer] 🎯 STATE CHANGED TO LOGIN SCREEN!")
      return .concatenate(
        .cancel(id: CancelID.splashRouting),
        .cancel(id: CancelID.staffEffects),
        .cancel(id: CancelID.memberEffects)
      )
    }
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
        await send(.view(.presentStaff))
      }
      .cancellable(id: CancelID.splashRouting, cancelInFlight: true)

    case .splash(.navigation(.presentMember)):
      return .run { send in
        await send(.view(.presentMember))
      }
      .cancellable(id: CancelID.splashRouting, cancelInFlight: true)

    case .auth(.navigation(.presentStaff)):
      return .concatenate(
        .cancel(id: CancelID.authEffects),
        .send(.view(.presentStaff))
      )

    case .auth(.navigation(.presentMember)):
      return .concatenate(
        .cancel(id: CancelID.authEffects),
        .send(.view(.presentMember))
      )

    case .staff(.navigation(.presentLogin)):
      return .concatenate(
        .cancel(id: CancelID.staffEffects),
        .send(.view(.presentAuth))
      )

    case .staff(.navigation(.presentMember)):
      return .concatenate(
        .cancel(id: CancelID.staffEffects),
        .send(.view(.presentMember))
      )

    case .member(.navigation(.presentLogin)):
      return .concatenate(
        .cancel(id: CancelID.memberEffects),
        .send(.view(.presentAuth))
      )

    case .member(.navigation(.presentStaff)):
      return .concatenate(
        .cancel(id: CancelID.memberEffects),
        .send(.view(.presentStaff))
      )

    default:
      return .none
    }
  }

  /// Refresh token 만료 감지 리스너 설정
  private func setupRefreshTokenExpiredListener() -> Effect<Action> {
    #logDebug("🔔 [AppReducer] 🚨 SETTING UP REFRESH TOKEN EXPIRED LISTENER...")
    return .publisher {
      NotificationCenter.default
        .publisher(for: NSNotification.Name("RefreshTokenExpired"))
        .map { notification in
          #logDebug("🔔 [AppReducer] 🔥 🎯 REFRESH TOKEN EXPIRED NOTIFICATION RECEIVED!")
          #logDebug("🔔 [AppReducer] Notification details: \(notification)")
          return Action.async(.refreshTokenExpired)
        }
    }
  }
}
