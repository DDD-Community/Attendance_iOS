//
//  CustomDate.swift
//  DesignSystem
//
//  Created by Wonji Suh  on 2/8/25.
//

import Foundation
import ComposableArchitecture

@Reducer
public struct CustomDate {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    public init() {}
  }
  
  public enum Action: Equatable , BindableAction{
    case binding(BindingAction<State>)
    case view(View)
  }
  
  public enum View: Equatable {
    case movePreviousMonth
    case moveNextMonth
  }
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding(_):
        return .none
        
        
      case .view(let viewAction):
        return handleViewAction(state: &state, action: viewAction)
      }
    }
  }
  
  fileprivate func handleViewAction(state: inout State, action: View) -> Effect<Action> {
    switch action {
    case .movePreviousMonth:
      return .none
    case .moveNextMonth:
      return .none
    }
  }
}

