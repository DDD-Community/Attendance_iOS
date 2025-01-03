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
  enum State {
    case splash(Splash.State)
    case auth(AuthCoordinator.State)
    case coreMember(CoreMemberCoordinator.State)
    case member(MemberCoordinator.State)
    
    init() {
      self = .splash(.init())
    }
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
    case coreMember(CoreMemberCoordinator.Action)
    case member(MemberCoordinator.Action)
  }
  
  @Dependency(\.continuousClock) var clock
  
  var body: some  ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .view(let ViewAction):
        handleViewAction(&state, action: ViewAction)
      }
    }
    .ifCaseLet(\.splash, action: \.view.splash) {
      Splash()
    }
    .ifCaseLet(\.auth, action: \.view.auth) {
      AuthCoordinator()
    }
    .ifCaseLet(\.coreMember, action: \.view.coreMember) {
      CoreMemberCoordinator()
    }
    .ifCaseLet(\.member, action: \.view.member) {
      MemberCoordinator()
    }
  }
  
  func handleViewAction(
    _ state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
      //MARK: - 로그인 화면 으로
    case .presentAuth:
      state = .auth(.init())
      return .none
      
    case .presentCoreMember:
      state = .coreMember(.init())
      return .none
      
    case .presentMember:
      state = .member(.init())
      return .none
      
    case .splash(.navigation(.presentLogin)):
      return .run { send in
        try await clock.sleep(for: .seconds(2))
        await send(.view(.presentAuth))
      }
      
    case .splash(.navigation(.presentCoreMember)):
      return .run { send in
        try await clock.sleep(for: .seconds(2))
        await send(.view(.presentCoreMember))
      }
      
    case .splash(.navigation(.presentMember)):
      return .run { send in
        try await clock.sleep(for: .seconds(2))
        await send(.view(.presentMember))
      }
      
    case .auth(.navigation(.presentCoreMember)):
      return .send(.view(.presentCoreMember))
      
    case .auth(.navigation(.presentMember)):
      return .send(.view(.presentMember))
      
    case .coreMember(.navigation(.presentLogin)):
      return .send(.view(.presentAuth))
      
    default:
      return .none
    }
  }
}
