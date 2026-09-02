//
//  OnBoardingName.swift
//  Presentation
//
//  Created by DDD on 11/3/24.
//

import Foundation

import DDDCoreUtility
import Entity

import ComposableArchitecture

@Reducer
public struct OnBoardingName {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    public init() {}

    @Shared(.inMemory("UserSession")) var userSession: UserSession = .empty

    
    var isNotAvailableName: Bool = false
    var enableButton: Bool {
      return !userSession.name.isEmpty && !isNotAvailableName
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
  @CasePathable
  public enum NavigationAction: Equatable {
    case presentSignUpPart
  }
  
  public var body: some Reducer<State, Action> {
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
}

extension OnBoardingName {
  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
    case .checkIsAvailableName:
      if state.userSession.name.count > 5 {
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
      // 이름 초기화 로직 제거 - 사용자가 입력한 이름을 유지
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
