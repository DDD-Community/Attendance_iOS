//
//  SignUpPart.swift
//  Presentation
//
//  Created by Wonji Suh  on 11/3/24.
//

import Foundation
import ComposableArchitecture

import Utill
import Networkings

@Reducer
public struct SignUpPart {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    public init() {}
    
    @Shared(.inMemory("Member")) var userSignUpMember: Member = .init()
    var activeSelectPart: Bool = false
    var selectPart: SelectPart? = .all
  }
  
  public enum Action: ViewAction, BindableAction, FeatureAction {
    case binding(BindingAction<State>)
    case view(View)
    case async(AsyncAction)
    case inner(InnerAction)
    case navigation(NavigationAction)
  }
  
  // MARK: - ViewAction
  
  @CasePathable
  public enum View {
    case selectPartButton(selectPart: SelectPart)
  }
  
  // MARK: - AsyncAction 비동기 처리 액션
  
  public enum AsyncAction: Equatable {
    
  }
  
  // MARK: - 앱내에서 사용하는 액션
  
  public enum InnerAction: Equatable {
    
  }
  
  // MARK: - NavigationAction
  
  public enum NavigationAction: Equatable {
    case presentManging
    case presentSelectTeam
    case presentNextStep
  }
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding(_):
        return .none
        
      case .view(let viewAction):
        return handleViewAction(state: &state, action: viewAction)
        
      case .async(let asyncAction):
        return handleAsyncAction(state: &state, action: asyncAction)
        
      case .inner(let innerAction):
        return handleInnerAction(state: &state, action: innerAction)
        
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
      
    case .selectPartButton(let selectPart):
      if state.selectPart == selectPart {
        state.selectPart = nil
        state.userSignUpMember.role = nil
        state.activeSelectPart = false
        return .none
      }
      
      state.selectPart = selectPart
      if let part = SelectPart(rawValue: selectPart.desc) {
        state.userSignUpMember.role = part
      }
      state.activeSelectPart = true
      return .none
    }
  }
  
  private func handleNavigationAction(
    state: inout State,
    action: NavigationAction
  ) -> Effect<Action> {
    switch action {
    case .presentManging:
      return .none
    case .presentSelectTeam:
      return .none
    case .presentNextStep:
      return .run { [isAdmin = state.userSignUpMember.isAdmin] send in
        if isAdmin == true {
          await send(.navigation(.presentManging))
        } else {
          await send(.navigation(.presentSelectTeam))
        }
      }
    }
  }
  
  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {
      
    }
  }
  
  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {
      
    }
  }
}
