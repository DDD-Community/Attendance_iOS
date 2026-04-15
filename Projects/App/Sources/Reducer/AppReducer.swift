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

  private enum CancelID: Hashable {
    case refreshTokenExpiredListener
    case splashRouting
    case authEffects
    case staffEffects
    case memberEffects
    case allStaffEffects
    case allMemberEffects
    case allAuthEffects

    // 🔥 PFW 패턴: 각 coordinator의 하위 effects
    case staffProfile
    case memberProfile
    case staffRouter
    case memberRouter
    case authRouter
  }

  // 🔥 개선: 공통 취소 패턴을 Helper 함수로 추출
  private func cancelAllEffects() -> Effect<Action> {
    let cancelIDs: [any Hashable & Sendable] = [
      CancelID.splashRouting,
      CancelID.authEffects,
      CancelID.staffEffects,
      CancelID.memberEffects,
      CancelID.allStaffEffects,
      CancelID.allMemberEffects,
      CancelID.allAuthEffects,
      StaffCoordinator.CancelID.allEffects,
      StaffCoordinator.CancelID.profileEffects,
      MemberCoordinator.CancelID.allEffects,
      MemberCoordinator.CancelID.profileEffects,
      ProfileReducer.CancelID.fetchProfile,
      ProfileReducer.CancelID.deleteUser,
      ProfileReducer.CancelID.logoutUser
    ]

    #logDebug("[AppReducer] 🚫 Cancelling all effects: \(cancelIDs.count) effects")
    return .merge(cancelIDs.map { .cancel(id: $0) })
  }

  // 🔥 PFW 패턴: 더 강력한 effect cancellation
  private func cancelAllCoordinatorEffects(excluding: CancelID) -> Effect<Action> {
    let coordinatorCancelIDs: [any Hashable & Sendable] = [
      // AppReducer CancelIDs
      CancelID.authEffects,
      CancelID.staffEffects,
      CancelID.memberEffects,
      CancelID.allStaffEffects,
      CancelID.allMemberEffects,
      CancelID.allAuthEffects,
      CancelID.staffProfile,
      CancelID.memberProfile,
      CancelID.staffRouter,
      CancelID.memberRouter,
      CancelID.authRouter,

      // Coordinator CancelIDs (존재할 경우)
      // StaffCoordinator.CancelID.allEffects,
      // StaffCoordinator.CancelID.profileEffects,
      // MemberCoordinator.CancelID.allEffects,
      // MemberCoordinator.CancelID.profileEffects,

      // Feature CancelIDs (존재할 경우)
      // ProfileReducer.CancelID.fetchProfile,
      // ProfileReducer.CancelID.deleteUser,
      // ProfileReducer.CancelID.logoutUser
    ].filter { id in
      // 현재 활성화될 Coordinator는 제외
      if let cancelID = id as? CancelID, cancelID == excluding {
        return false
      }
      return true
    }

    #logDebug("[AppReducer] 🚫 Cancelling coordinator effects: \(coordinatorCancelIDs.count) effects, excluding: \(excluding)")
    return .merge(coordinatorCancelIDs.map { .cancel(id: $0) })
  }

  public var body: some ReducerOf<Self> {
    // 🔥 PFW 베스트 프랙티스: Reduce를 먼저 배치하여 상태 검증
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

    // 🔥 Child reducers는 상태 검증 후에 결합
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
      return cancelCoordinatorEffects(excluding: .memberEffects)

    case .presentAuth:
      #logDebug("[AppReducer] 🔄 Transitioning to AUTH state")
      state = .auth(.init())
      return .merge(
        cancelCoordinatorEffects(excluding: .authEffects),
        .cancel(id: CancelID.allStaffEffects),
        .cancel(id: CancelID.allMemberEffects)
      )

    case .presentStaff:
      #logDebug("[AppReducer] 🔄 Transitioning to STAFF state")
      state = .staff(.init())
      return .merge(
        cancelCoordinatorEffects(excluding: .staffEffects),
        .cancel(id: CancelID.allAuthEffects),
        .cancel(id: CancelID.allMemberEffects)
      )

    case .presentMember:
      #logDebug("[AppReducer] 🔄 Transitioning to MEMBER state")
      state = .member(.init())
      return .merge(
        cancelCoordinatorEffects(excluding: .memberEffects),
        .cancel(id: CancelID.allAuthEffects),
        .cancel(id: CancelID.allStaffEffects)
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
    // 🔥 PFW 패턴: 상태 전환 액션 체크
    if isStateTransitionAction(action) {
      return handleStateTransitionAction(state: &state, action: action)
    }

    // 🔥 상태-액션 매칭 검증 (비-전환 액션들)
    switch (state, action) {
    case (.auth, .staff), (.auth, .member):
      #logDebug("[AppReducer] 🚫 Ignoring \(action) while in auth state")
      return .none
    case (.staff, .auth), (.staff, .member):
      #logDebug("[AppReducer] 🚫 Ignoring \(action) while in staff state")
      return .none
    case (.member, .auth), (.member, .staff):
      #logDebug("[AppReducer] 🚫 Ignoring \(action) while in member state")
      return .none
    case (.splash, _):
      break // splash에서는 모든 액션 허용
    default:
      break // 같은 상태의 액션은 허용
    }

    // 🔥 일반 scope 액션들은 child reducer가 처리
    return .none
  }

  // 🔥 PFW 패턴: 상태 전환 액션 식별
  private func isStateTransitionAction(_ action: ScopeAction) -> Bool {
    switch action {
    case .splash(.navigation(.presentLogin)),
         .splash(.navigation(.presentStaff)),
         .splash(.navigation(.presentMember)),
         .auth(.navigation(.presentStaff)),
         .auth(.navigation(.presentMember)),
         .staff(.navigation(.presentLogin)),
         .staff(.navigation(.presentMember)),
         .member(.navigation(.presentLogin)),
         .member(.navigation(.presentStaff)):
      return true
    default:
      return false
    }
  }

  // 🔥 PFW 패턴: 원자적 상태 전환 처리
  private func handleStateTransitionAction(
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
      #logDebug("[AppReducer] 🔄 Splash → STAFF transition")
      return .merge(
        cancelAllCoordinatorEffects(excluding: .staffEffects),
        .run { send in
          await send(.view(.presentStaff))
        }
      )

    case .splash(.navigation(.presentMember)):
      #logDebug("[AppReducer] 🔄 Splash → MEMBER transition")
      return .merge(
        cancelAllCoordinatorEffects(excluding: .memberEffects),
        .run { send in
          await send(.view(.presentMember))
        }
      )

    case .auth(.navigation(.presentStaff)):
      #logDebug("[AppReducer] 🔄 Auth → STAFF transition")
      return .merge(
        cancelAllCoordinatorEffects(excluding: .staffEffects),
        .run { send in
          await send(.view(.presentStaff))
        }
      )

    case .auth(.navigation(.presentMember)):
      #logDebug("[AppReducer] 🔄 Auth → MEMBER transition")
      return .merge(
        cancelAllCoordinatorEffects(excluding: .memberEffects),
        .run { send in
          await send(.view(.presentMember))
        }
      )

    case .staff(.navigation(.presentLogin)):
      #logDebug("[AppReducer] 🔄 Staff → AUTH transition")
      return .merge(
        cancelAllCoordinatorEffects(excluding: .authEffects),
        .run { send in
          await send(.view(.presentAuth))
        }
      )

    case .staff(.navigation(.presentMember)):
      #logDebug("[AppReducer] 🔄 Staff → MEMBER transition")
      return .merge(
        cancelAllCoordinatorEffects(excluding: .memberEffects),
        .run { send in
          await send(.view(.presentMember))
        }
      )

    case .member(.navigation(.presentLogin)):
      #logDebug("[AppReducer] 🔄 Member → AUTH transition")
      return .merge(
        cancelAllCoordinatorEffects(excluding: .authEffects),
        .run { send in
          await send(.view(.presentAuth))
        }
      )

    case .member(.navigation(.presentStaff)):
      #logDebug("[AppReducer] 🔄 Member → STAFF transition")
      return .merge(
        cancelAllCoordinatorEffects(excluding: .staffEffects),
        .run { send in
          await send(.view(.presentStaff))
        }
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
