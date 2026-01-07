//
//  AppReducer.swift
//  DDDAttendance
//
//  Created by Wonji Suh  on 10/29/24.
//

import Presentation

import ComposableArchitecture
import Entity

@Reducer
struct AppReducer {

  // MARK: - State
  @ObservableState
  struct State: Equatable {
    var splash: Splash.State?
    var auth: AuthCoordinator.State?
    var staff: StaffCoordinator.State?
    var member: MemberCoordinator.State?
//    @Shared(.appStorage("staffRole")) var staffRole: Staff?

    init() {
      self.splash = .init()
      self.auth = nil
      self.staff = nil
      self.member = nil
    }
  }

  // MARK: - Action
  enum Action: ViewAction {
    case view(View)
    case inner(InnerAction)
    case scope(ScopeAction)
  }

  enum Flow {
    case splash
    case auth
    case staff
    case member
  }

  @CasePathable
  enum View {
    case presentAuth
    case presentStaff
    case presentMember
  }

  enum InnerAction {
    case setAuthState
    case setStaffState
    case setMemberState
  }

  @CasePathable
  enum ScopeAction {
    case splash(Splash.Action)
    case auth(AuthCoordinator.Action)
    case staff(StaffCoordinator.Action)
    case member(MemberCoordinator.Action)
  }

  @Dependency(\.continuousClock) var clock

  nonisolated enum CancelID: Hashable {
    case splashNavigation
    case authEffects
    case coreMemberEffects
    case memberEffects
    case allAuthRelatedEffects
  }

  // MARK: - body
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .view(let viewAction):
        return handleViewAction(&state, action: viewAction)
      case .inner(let innerAction):
        return handleInnerAction(&state, action: innerAction)
      case .scope(let scopeAction):
        return handleScopeAction(&state, action: scopeAction)
      }
    }
    .ifLet(\.splash, action: \.scope.splash) {
      Splash()
    }
    .ifLet(\.auth, action: \.scope.auth) {
      AuthCoordinator()
    }
    .ifLet(\.staff, action: \.scope.staff) {
      StaffCoordinator()
    }
    .ifLet(\.member, action: \.scope.member) {
      MemberCoordinator()
    }
  }
}

extension AppReducer.State {
  var flow: AppReducer.Flow {
    if member != nil { return .member }
    if staff != nil { return .staff }
    if auth != nil { return .auth }
    return .splash
  }

  var caseKey: String {
    if member != nil { return "member" }
    if staff != nil { return "staff" }
    if auth != nil { return "auth" }
    return "splash"
  }
}

extension AppReducer {
  func handleViewAction(
    _ state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
    case .presentAuth:
      return .merge(
        .cancel(id: CancelID.splashNavigation),
        .cancel(id: CancelID.coreMemberEffects),
        .cancel(id: CancelID.memberEffects),
        .send(.inner(.setAuthState))
      )

    case .presentStaff:
      return .merge(
        .cancel(id: CancelID.splashNavigation),
        .cancel(id: CancelID.authEffects),
        .cancel(id: CancelID.memberEffects),
        .send(.inner(.setStaffState))
      )

    case .presentMember:
      return .merge(
        .cancel(id: CancelID.splashNavigation),
        .cancel(id: CancelID.authEffects),
        .cancel(id: CancelID.coreMemberEffects),
        .send(.inner(.setMemberState))
      )
    }
  }

  func handleInnerAction(
    _ state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {
    case .setAuthState:
      state.auth = .init()
      state.splash = nil
      state.staff = nil
      state.member = nil
      return .merge(
        .cancel(id: CancelID.coreMemberEffects),
        .cancel(id: CancelID.memberEffects)
      )

    case .setStaffState:
      state.staff = .init()
      state.splash = nil
      state.auth = nil
      state.member = nil
      return .merge(
        .cancel(id: CancelID.allAuthRelatedEffects),
        .cancel(id: CancelID.authEffects)
      )

    case .setMemberState:
      state.member = .init()
      state.splash = nil
      state.auth = nil
      state.staff = nil
      return .merge(
        .cancel(id: CancelID.allAuthRelatedEffects),
        .cancel(id: CancelID.authEffects),
        .cancel(id: CancelID.coreMemberEffects)
      )
    }
  }

  func handleScopeAction(
    _ state: inout State,
    action: ScopeAction
  ) -> Effect<Action> {
    switch action {
    case .splash(.navigation(.presentLogin)):
      return .run { send in
        try await clock.sleep(for: .seconds(1))
        await send(.view(.presentAuth))
      }
      .cancellable(id: CancelID.splashNavigation, cancelInFlight: true)

    case .splash(.navigation(.presentStaff)):
      return .run { send in
        try await clock.sleep(for: .seconds(1))
        await send(.view(.presentStaff))
      }
      .cancellable(id: CancelID.splashNavigation, cancelInFlight: true)

    case .splash(.navigation(.presentMember)):
      return .run { send in
        try await clock.sleep(for: .seconds(1))
        await send(.view(.presentMember))
      }
      .cancellable(id: CancelID.splashNavigation, cancelInFlight: true)

    case .auth(.navigation(.presentStaff)):
      return .merge(
        .cancel(id: CancelID.allAuthRelatedEffects),
        .send(.view(.presentStaff))
      )
      .cancellable(id: CancelID.authEffects, cancelInFlight: true)

    case .auth(.navigation(.presentMember)):
      return .merge(
        .cancel(id: CancelID.allAuthRelatedEffects),
        .send(.view(.presentMember))
      )
      .cancellable(id: CancelID.authEffects, cancelInFlight: true)

    case .staff(.navigation(.presentLogin)):
      return .merge(
        .cancel(id: CancelID.coreMemberEffects),
        .send(.view(.presentAuth))
      )

    case .staff(.navigation(.presentMember)):
      return .send(.view(.presentMember))

    case .member(.navigation(.presentLogin)):
      return .merge(
        .cancel(id: CancelID.memberEffects),
        .send(.view(.presentAuth))
      )

    case .member(.navigation(.presentStaff)):
      return .send(.view(.presentStaff))

    case let .auth(authAction):
      // auth state가 nil인 경우 모든 auth 액션 무시
      guard state.auth != nil else {
        print("🚫 [AppReducer] Ignoring auth action - auth state is nil: \(authAction)")
        return .none
      }
      return .none

    case .staff:
      // staff state가 nil인 경우 무시
      guard state.staff != nil else { return .none }
      return .none

    case .member:
      // member state가 nil인 경우 무시
      guard state.member != nil else { return .none }
      return .none

    default:
      return .none
    }
  }
}
