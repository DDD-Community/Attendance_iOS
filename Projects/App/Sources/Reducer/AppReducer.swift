//
//  AppReducer.swift
//  DDDAttendance
//
//  Created by Wonji Suh  on 10/29/24.
//

import Presentation

import ComposableArchitecture

@Reducer
struct AppReducer {

  @ObservableState
  enum State: Equatable {
    case splash(Splash.State)
    case auth(AuthCoordinator.State)
    case staff(StaffCoordinator.State)
    case member(MemberCoordinator.State)

    init() {
      self = .splash(.init())
    }

    var screenType: ScreenType {
      switch self {
      case .splash: return .splash
      case .auth: return .auth
      case .staff: return .coreMember
      case .member: return .member
      }
    }
  }

  enum ScreenType: Equatable {
    case splash, auth, coreMember, member
  }

  enum Action: ViewAction {
    case view(View)
  }

  @CasePathable
  enum View {
    case presentAuth
    case presentStaff
    case presentMember

    case splash(Splash.Action)
    case auth(AuthCoordinator.Action)
    case staff(StaffCoordinator.Action)
    case member(MemberCoordinator.Action)
  }

  @Dependency(\.continuousClock) var clock

  var body: some ReducerOf<Self> {
   EmptyReducer()
    .ifCaseLet(\.splash, action: \.view.splash) {
      Splash()
    }
    .ifCaseLet(\.auth, action: \.view.auth) {
      AuthCoordinator()
    }
    .ifCaseLet(\.staff, action: \.view.staff) {
      StaffCoordinator()
    }
    .ifCaseLet(\.member, action: \.view.member) {
      MemberCoordinator()
    }
    Reduce { state, action in
      switch action {
      case .view(let ViewAction):
        return handleViewAction(&state, action: ViewAction)
      }
    }
  }
}

// MARK: - Effect Cancellation IDs
private enum CancelID: Hashable {
  case splashNavigation
  case authEffects
  case coreMemberEffects
  case memberEffects
  case allAuthRelatedEffects
}

extension AppReducer {
  func handleViewAction(
    _ state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
      // MARK: - 로그인 화면으로
    case .presentAuth:
      state = .auth(.init())
      return .merge(
        .cancel(id: CancelID.splashNavigation),
        .cancel(id: CancelID.coreMemberEffects),
        .cancel(id: CancelID.memberEffects)
      )

    case .presentStaff:
      state = .staff(.init())
      return .merge(
        .cancel(id: CancelID.splashNavigation),
        .cancel(id: CancelID.authEffects),
        .cancel(id: "allAuthRelatedEffects"),
        .cancel(id: CancelID.memberEffects)
      )

    case .presentMember:
      state = .member(.init())
      return .merge(
        .cancel(id: CancelID.splashNavigation),
        .cancel(id: CancelID.authEffects),
        .cancel(id: "allAuthRelatedEffects"),
        .cancel(id: CancelID.coreMemberEffects)
      )

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
        .cancel(id: "allAuthRelatedEffects"),
        .send(.view(.presentStaff))
      )
      .cancellable(id: CancelID.authEffects, cancelInFlight: true)

    case .auth(.navigation(.presentMember)):
      return .merge(
        .cancel(id: "allAuthRelatedEffects"),
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

    case .splash, .staff, .member:
      return .none

    case .auth:
      if case .auth = state {
        return .none
      } else {
        return .none
      }
    }
  }
}
