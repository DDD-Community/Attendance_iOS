//
//  SignUpSelectManging.swift
//  Presentation
//
//  Created by Wonji Suh  on 11/3/24.
//

import Foundation

import Foundation
import ComposableArchitecture

import Utill
import Model

@Reducer
public struct SignUpSelectManging {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    public init() {}
    var selectMangingPart : Managing? = .notManging
    var activeButton: Bool = false
    @Shared(.inMemory("Member")) var userSignUpMember: Member = .init()
  }
  
  public enum Action: ViewAction, BindableAction, FeatureAction {
    case binding(BindingAction<State>)
    case view(View)
    case async(AsyncAction)
    case inner(InnerAction)
    case navigation(NavigationAction)
  }
  
  //MARK: - ViewAction
  @CasePathable
  public enum View {
    case selectMangingButton(selectManging: Managing)
  }
  
  
  
  //MARK: - AsyncAction 비동기 처리 액션
  public enum AsyncAction: Equatable {
    
  }
  
  //MARK: - 앱내에서 사용하는 액션
  public enum InnerAction: Equatable {
    
  }
  
  //MARK: - NavigationAction
  public enum NavigationAction: Equatable {
    
    
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
      case .selectMangingButton(let selectManging):
        if state.selectMangingPart == selectManging {
          state.selectMangingPart = nil
          state.userSignUpMember.manging = nil
          state.activeButton = false
          return .none
        }
        
        state.selectMangingPart = selectManging
        state.userSignUpMember.manging = selectManging
        state.activeButton = true
        return .none
      }
  }
  
  private func handleNavigationAction(
    state: inout State,
    action: NavigationAction
  ) -> Effect<Action> {
    switch action {
   
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
