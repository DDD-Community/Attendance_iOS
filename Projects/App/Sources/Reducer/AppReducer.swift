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
    case coreMember(StaffCoordinator.State)
    case member(MemberCoordinator.State)

    init() {
      self = .splash(.init())
    }

    var screenType: ScreenType {
      switch self {
      case .splash: return .splash
      case .auth: return .auth
      case .coreMember: return .coreMember
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
    case presentCoreMember
    case presentMember

    case splash(Splash.Action)
    case auth(AuthCoordinator.Action)
    case coreMember(StaffCoordinator.Action)
    case member(MemberCoordinator.Action)
  }

  @Dependency(\.continuousClock) var clock

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .view(let ViewAction):
        return handleViewAction(&state, action: ViewAction)
      }
    }
    .ifCaseLet(\.splash, action: \.view.splash) {
      Splash()
    }
    .ifCaseLet(\.auth, action: \.view.auth) {
      AuthCoordinator()
    }
    .ifCaseLet(\.coreMember, action: \.view.coreMember) {
      StaffCoordinator()
    }
    .ifCaseLet(\.member, action: \.view.member) {
      MemberCoordinator()
    }
  }
}

// MARK: - Effect Cancellation IDs
private enum CancelID: Hashable {
  case splashNavigation
  case authEffects
  case coreMemberEffects
  case memberEffects
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

    case .presentCoreMember:
      state = .coreMember(.init())
      return .merge(
        .cancel(id: CancelID.splashNavigation),
        .cancel(id: CancelID.authEffects),
        .cancel(id: CancelID.memberEffects)
      )

    case .presentMember:
      state = .member(.init())
      return .merge(
        .cancel(id: CancelID.splashNavigation),
        .cancel(id: CancelID.authEffects),
        .cancel(id: CancelID.coreMemberEffects)
      )

    case .splash(.navigation(.presentLogin)):
      return .run { send in
        try await clock.sleep(for: .seconds(1))
        await send(.view(.presentAuth))
      }
      .cancellable(id: CancelID.splashNavigation)

    case .splash(.navigation(.presentStaff)):
      return .run { send in
        try await clock.sleep(for: .seconds(1))
        await send(.view(.presentCoreMember))
      }
      .cancellable(id: CancelID.splashNavigation)

    case .splash(.navigation(.presentMember)):
      return .run { send in
        try await clock.sleep(for: .seconds(1))
        await send(.view(.presentMember))
      }
      .cancellable(id: CancelID.splashNavigation)

    case .auth(.navigation(.presentCoreMember)):
      return .merge(
        .send(.view(.auth(.navigation(.cleanup)))),
        .send(.view(.presentCoreMember))
      )
      .cancellable(id: CancelID.authEffects)

    case .auth(.navigation(.presentMember)):
      return .merge(
        .send(.view(.auth(.navigation(.cleanup)))),
        .send(.view(.presentMember))
      )
      .cancellable(id: CancelID.authEffects)

    case .coreMember(.navigation(.presentLogin)):
      return .merge(
        .cancel(id: CancelID.coreMemberEffects),
        .send(.view(.presentAuth))
      )

    case .member(.navigation(.presentLogin)):
      return .merge(
        .cancel(id: CancelID.memberEffects),
        .send(.view(.presentAuth))
      )

    case .splash, .coreMember, .member:
      return .none

    case .auth:
      // auth 액션이 들어왔는데 현재 상태가 auth가 아니면 무시
      if case .auth = state {
        return .none
      } else {
        return .none
      }
    }
  }
}
