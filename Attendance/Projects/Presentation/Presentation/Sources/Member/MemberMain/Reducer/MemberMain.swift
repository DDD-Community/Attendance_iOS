//
//  MemberMain.swift
//  Presentation
//
//  Created by 홍은표 on 1/2/25.
//

import Foundation

import Utill

import ComposableArchitecture

@Reducer
public struct MemberMain {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    
  }
  
  public enum Action: ViewAction, BindableAction, FeatureAction {
    case binding(BindingAction<State>)
    case view(View)
    case inner(InnerAction)
    case async(AsyncAction)
    case navigation(NavigationAction)
  }
  
  @CasePathable
  public enum View {
    
  }
  
  public enum AsyncAction: Equatable {
    
  }

  public enum InnerAction: Equatable {
    
  }
  
  public enum NavigationAction: Equatable {
    
  }
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    
    Reduce { state, action in
      switch action {
      case .binding:
        return .none
        
      case .view(let action):
        return handleViewAction(state: &state, action: action)
        
      case .inner(let action):
        return handleInnerAction(state: &state, action: action)
        
      case .async(let action):
        return handleAsyncAction(state: &state, action: action)
        
      case .navigation(let action):
        return handleNavigationAction(state: &state, action: action)
      }
    }
  }
  
  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    
  }
  
  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    
  }
  
  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    
  }
  
  private func handleNavigationAction(
    state: inout State,
    action: NavigationAction
  ) -> Effect<Action> {
    
  }
}
