//
//  Login.swift
//  Presentation
//
//  Created by Wonji Suh  on 10/29/24.
//

import Foundation
import ComposableArchitecture

import Utill

@Reducer
public struct Login {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    public init() {}
  
    var nonce: String = ""
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
        
        
      case .view(let View):
        switch View {
          
        }
        
      case .async(let AsyncAction):
        switch AsyncAction {
          
        }
        
      case .inner(let InnerAction):
        switch InnerAction {
          
        }
        
      case .navigation(let NavigationAction):
        switch NavigationAction {
          
        }
      }
    }
  }
}
