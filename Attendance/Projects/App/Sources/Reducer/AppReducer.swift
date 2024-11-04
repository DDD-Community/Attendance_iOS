//
//  AppReducer.swift
//  DDDAttendance
//
//  Created by Wonji Suh  on 10/29/24.
//

import ComposableArchitecture
import Presentation


@Reducer
struct AppReducer {
  
  @ObservableState
  enum State {
    case splash(Splash.State)
    case auth(AuthCoordinator.State)
    case coreMember(CoreMemberCoordinator.State)
   
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
    case presntCoreMember
    
    case splash(Splash.Action)
    case auth(AuthCoordinator.Action)
    case coreMember(CoreMemberCoordinator.Action)
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
      
    case .presntCoreMember:
      state = .coreMember(.init())
      return .none
      
    case .splash(.navigation(.presentLogin)):
      return .run { send in
        try await clock.sleep(for: .seconds(2))
        await send(.view(.presentAuth))
      }
      
    case .splash(.navigation(.presentCoreMember)):
      return .run { send in
        try await clock.sleep(for: .seconds(2))
        await send(.view(.presntCoreMember))
      }
      
    case .auth(.navigation(.presentCoreMember)):
      return .send(.view(.presntCoreMember))
      
    case .coreMember(.navigation(.presntLogin)):
      return .send(.view(.presentAuth))
      
    default:
      return .none
    }
  }
  
}
