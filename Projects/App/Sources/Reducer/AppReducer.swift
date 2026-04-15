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

  // 🎯 PFW 패턴: 강타입 최소 CancelID (3개로 축소)
  private enum CancelID: Hashable {
    case coordinator(CoordinatorType)
    case transition
    case refreshTokenListener

    enum CoordinatorType: Hashable {
      case staff
      case member
      case auth
    }
  }

  // 🎯 PFW 패턴: 최소한의 핵심 취소 (3개만)
  private func cancelAllCoordinatorEffects() -> Effect<Action> {
    return .merge([
      // PFW 권장: 최소한의 핵심 Coordinator Effect 취소
      .cancel(id: CancelID.coordinator(.staff)),
      .cancel(id: CancelID.coordinator(.member)),
      .cancel(id: CancelID.coordinator(.auth)),

      // ProfileReducer 핵심 Effect만
      .cancel(id: ProfileReducer.CancelID.fetchProfile),
      .cancel(id: ProfileReducer.CancelID.deleteUser),
      .cancel(id: ProfileReducer.CancelID.logoutUser)
    ])
  }

  // 🎯 PFW 패턴: 단순한 상태 전환
  private func transitionToState() -> Effect<Action> {
    return .concatenate(
      cancelAllCoordinatorEffects(),
      .run { _ in await Task.yield() } // 메모리 정리
    )
    .cancellable(id: CancelID.transition, cancelInFlight: true)
  }

  // 제거됨: PFW 권장사항에 따라 단순화

  public var body: some ReducerOf<Self> {
    // 🔥 TCA 해결책 4: Reduce를 ifCaseLet보다 먼저 배치하여 액션 필터링 우선 처리
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
        // 🎯 PFW 패턴: 단순한 위임 - 복잡한 검증은 handleScopeAction에서
        return handleScopeAction(state: &state, action: scopeAction)
      }
    }
    // 🔥 TCA 해결책 5: 강화된 ifCaseLet 체인 - 상태 불일치 방어
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
      // 🎯 PFW 패턴: 간단한 루트 전환
      state = .member(.init())
      return transitionToState()

    case .presentAuth:
      // 🔥 TCA 해결책 3: Auth 전환 원자성 보장
      state = .auth(.init())
      return transitionToState()

    case .presentStaff:
      // 🔥 TCA 해결책 4: Staff 전환 원자성 보장
      state = .staff(.init())
      return transitionToState()

    case .presentMember:
      // 🔥 TCA 해결책 5: Member 전환 원자성 보장
      state = .member(.init())
      return transitionToState()
    }
  }

  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {
    case .startNotificationListener:
      return setupRefreshTokenExpiredListener()
        .cancellable(id: CancelID.refreshTokenListener, cancelInFlight: true)

    case .refreshTokenExpired:
      // 🔥 TCA 해결책: 토큰 만료시 완전한 Effect 정리
      state = .auth(.init())
      return transitionToState()
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

  // 🎯 PFW 철학: 단순하고 조합 가능한 상태 검증
  private func isValidAction(_ action: ScopeAction, for state: State) -> Bool {
    switch (action, state) {
    case (.staff, .staff), (.member, .member), (.auth, .auth), (.splash, .splash):
      return true
    default:
      return false
    }
  }

  private func handleScopeAction(
    state: inout State,
    action: ScopeAction
  ) -> Effect<Action> {
    // 🎯 PFW 철학: 타입 안전한 상태 매칭
    switch (action, state) {
    case (.staff, .staff), (.member, .member),
         (.auth, .auth), (.splash, .splash):
      // ✅ 올바른 상태 매칭 - 네비게이션 처리 진행
      break

    case (.staff, _), (.member, _), (.auth, _), (.splash, _):
      // ✅ 상태 불일치 - PFW 철학: 조용히 무시
      return .none
    }

    // 🎯 PFW 패턴: 단순한 네비게이션 처리
    return handleScopeNavigation(action: action)
  }

  // 🎯 PFW 패턴: 네비게이션 로직 분리
  private func handleScopeNavigation(action: ScopeAction) -> Effect<Action> {
    switch action {
    case .splash(.navigation(.presentLogin)):
      return .run { send in
        try await clock.sleep(for: .seconds(0.5))
        await send(.view(.presentAuth))
      }
      .cancellable(id: CancelID.transition, cancelInFlight: true)

    case .splash(.navigation(.presentStaff)):
      return .send(.view(.presentStaff))

    case .splash(.navigation(.presentMember)):
      return .send(.view(.presentMember))

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

  // 🎯 PFW 패턴: 간결한 상태 검증
  private func isStaffState(_ state: State) -> Bool {
    guard case .staff = state else { return false }
    return true
  }

  private func isMemberState(_ state: State) -> Bool {
    guard case .member = state else { return false }
    return true
  }

  private func isAuthState(_ state: State) -> Bool {
    guard case .auth = state else { return false }
    return true
  }

  private func isSplashState(_ state: State) -> Bool {
    guard case .splash = state else { return false }
    return true
  }


  private func setupRefreshTokenExpiredListener() -> Effect<Action> {
    return .publisher {
      NotificationCenter.default
        .publisher(for: NSNotification.Name("RefreshTokenExpired"))
        .map { _ in Action.async(.refreshTokenExpired) }
    }
    .cancellable(id: CancelID.refreshTokenListener, cancelInFlight: true)
  }

}
