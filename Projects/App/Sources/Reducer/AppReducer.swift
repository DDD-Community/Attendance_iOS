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
import Management
import Member

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

  // 🔥 개선: 공통 취소 패턴을 Helper 함수로 추출
  private func cancelAllEffects() -> Effect<Action> {
    let cancelIDs: [any Hashable & Sendable] = [
      CancelID.splashRouting,
      CancelID.authEffects,
      CancelID.staffEffects,
      CancelID.memberEffects,
      StaffCoordinator.CancelID.allEffects,
      StaffCoordinator.CancelID.profileEffects,
      MemberCoordinator.CancelID.allEffects,
      MemberCoordinator.CancelID.profileEffects,
      ProfileReducer.CancelID.fetchProfile,
      ProfileReducer.CancelID.deleteUser,
      ProfileReducer.CancelID.logoutUser
    ]

    return .merge(cancelIDs.map { .cancel(id: $0) })
  }

  private func cancelCoordinatorEffects(excluding: CancelID) -> Effect<Action> {
    let coordinatorCancelIDs: [any Hashable & Sendable] = [
      CancelID.authEffects,
      CancelID.staffEffects,
      CancelID.memberEffects,
      StaffCoordinator.CancelID.allEffects,
      StaffCoordinator.CancelID.profileEffects,
      MemberCoordinator.CancelID.allEffects,
      MemberCoordinator.CancelID.profileEffects,
      ProfileReducer.CancelID.fetchProfile,
      ProfileReducer.CancelID.deleteUser,
      ProfileReducer.CancelID.logoutUser
    ].filter { id in
      // 현재 활성화될 Coordinator는 제외
      if let cancelID = id as? CancelID, cancelID == excluding {
        return false
      }
      return true
    }

    return .merge(coordinatorCancelIDs.map { .cancel(id: $0) })
  }

  public var body: some ReducerOf<Self> {
    // 🔥 TCA 해결책 1: Child reducer들을 먼저 결합
    EmptyReducer()
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

    // 🔥 Parent reducer는 마지막에 처리 + 디버그 로깅
    Reduce { state, action in
      // 🔍 디버그: action과 현재 state 로깅
      #logDebug("🎯 [AppReducer] Current State: \(state) | Incoming Action: \(action)")

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
        #logDebug("🔍 [AppReducer] Scope Action Received: \(scopeAction)")
        return handleScopeAction(state: &state, action: scopeAction)
      }
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
      return cancelCoordinatorEffects(excluding: .memberEffects)

    case .presentAuth:
      state = .auth(.init())
      return cancelCoordinatorEffects(excluding: .authEffects)

    case .presentStaff:
      state = .staff(.init())
      return cancelCoordinatorEffects(excluding: .staffEffects)

    case .presentMember:
      state = .member(.init())
      return cancelCoordinatorEffects(excluding: .memberEffects)
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
      return cancelAllEffects()
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
      .cancellable(id: CancelID.splashRouting, cancelInFlight: true)

    case .splash(.navigation(.presentStaff)):
      state = .staff(.init())
      return cancelCoordinatorEffects(excluding: .staffEffects)

    case .splash(.navigation(.presentMember)):
      state = .member(.init())
      return cancelCoordinatorEffects(excluding: .memberEffects)

    case .auth(.navigation(.presentStaff)):
      state = .staff(.init())
      return cancelCoordinatorEffects(excluding: .staffEffects)

    case .auth(.navigation(.presentMember)):
      state = .member(.init())
      return cancelCoordinatorEffects(excluding: .memberEffects)

    case .staff(.navigation(.presentLogin)):
      state = .auth(.init())
      return cancelCoordinatorEffects(excluding: .authEffects)

    case .staff(.navigation(.presentMember)):
      state = .member(.init())
      return cancelCoordinatorEffects(excluding: .memberEffects)

    case .member(.navigation(.presentLogin)):
      state = .auth(.init())
      return cancelCoordinatorEffects(excluding: .authEffects)

    case .member(.navigation(.presentStaff)):
      state = .staff(.init())
      return cancelCoordinatorEffects(excluding: .staffEffects)

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
