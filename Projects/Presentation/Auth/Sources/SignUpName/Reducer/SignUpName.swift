//
//  SignUpName.swift
//  Presentation
//
//  Created by Wonji Suh  on 11/3/24.
//

import Foundation

import Core
import Utill

import ComposableArchitecture

@Reducer
public struct SignUpName {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    public init() {}
    @Shared(.inMemory("UserEntity")) var userEntity: UserEntity = .shared
    
    
    var isNotAvailableName: Bool = false
    var enableButton: Bool {
      return !userEntity.signUpName.isEmpty && !isNotAvailableName
    }
  }
  
  public enum Action: ViewAction, BindableAction {
    case binding(BindingAction<State>)
    case view(View)
    case navigation(NavigationAction)
  }
  
  // MARK: - ViewAction
  
  @CasePathable
  public enum View {
    case checkIsAvailableName
    case initSignUpName
  }

  
  // MARK: - NavigationAction
  public enum NavigationAction: Equatable {
    case presentSignUpPart
  }
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding(_):
        return .none
        
      case .view(let viewAction):
        return handleViewAction(state: &state, action: viewAction)
          
      case .navigation(let navigationAction):
        return handleNavigationAction(state: &state, action: navigationAction)
      }
    }
  }
  
  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
    case .checkIsAvailableName:
      if state.userEntity.signUpName.count > 5 {
        state.isNotAvailableName = true
      } else {
        state.isNotAvailableName = false
      }
      return .run { [enableButton = state.enableButton] send in
        if enableButton == true {
          await send(.navigation(.presentSignUpPart))
        }
      }
      
    case .initSignUpName:
      state.$userEntity.withLock { $0.signUpName = "" }
      return .none
    }
  }
  
  private func handleNavigationAction(
    state: inout State,
    action: NavigationAction
  ) -> Effect<Action> {
    switch action {
    case .presentSignUpPart:
      return .none
    }
  }
}
