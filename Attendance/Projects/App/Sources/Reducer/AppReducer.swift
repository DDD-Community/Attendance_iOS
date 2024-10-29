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
    case login(Login.State)
   
    init() {
      self = .splash(.init())
    }
  }
  
  enum Action: ViewAction {
    case view(View)
  }
  
  @CasePathable
  enum View {
    case presntAuth
    case splash(Splash.Action)
    case login(Login.Action)
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
    .ifCaseLet(\.login, action: \.view.login) {
      Login()
    }
  }
  
  func handleViewAction(
    _ state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
    case .presntAuth:
      state = .login(.init())
      return .none
      
    case .splash(.navigation(.presntAuth)):
      return .run { send in
        try await clock.sleep(for: .seconds(4))
        await send(.view(.presntAuth))
      }
      
    default:
      return .none
    }
  }
  
}
