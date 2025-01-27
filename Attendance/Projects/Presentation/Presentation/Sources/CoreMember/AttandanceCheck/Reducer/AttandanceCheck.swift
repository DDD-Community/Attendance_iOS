//
//  AttandanceCheck.swift
//  Presentation
//
//  Created by Wonji Suh  on 1/16/25.
//

import Foundation
import ComposableArchitecture

import Utill
import Networkings

@Reducer
public struct AttandanceCheck {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    
    var selectAttandanceDate: Date = .now
    var selectPart: SelectTeam? = .web1
    var isActiveBoldText: Bool = false
    var dividerWidths: [SelectTeam: CGFloat] = [:]
    
    
    public init() {
      
    }
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
    case selectPartButton(selectPart: SelectTeam)
    case swipeNext
    case swipePrevious
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
    case .selectPartButton(let selectPart):
      state.selectPart = selectPart
      state.isActiveBoldText = (selectPart != nil)  // selectPart가 선택된 경우 bold text 활성화
      return .none
      
    case .swipeNext:
      guard let selectPart = state.selectPart else { return .none }
      if let currentIndex = SelectTeam.allCases.firstIndex(of: selectPart),
         currentIndex < SelectTeam.allCases.count - 1 {
        let nextPart = SelectTeam.allCases[currentIndex + 1]
        state.selectPart = nextPart
      }
      return .none
      
    case .swipePrevious:
      guard let selectPart = state.selectPart else { return .none }
      if let currentIndex = SelectTeam.allCases.firstIndex(of: selectPart),
         currentIndex > 0 {
        state.selectPart = SelectTeam.allCases[currentIndex - 1]
      }
      return .none
    }
  }
  
  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {
      
    }
  }
  
  private func handleNavigationAction(
    state: inout State,
    action: NavigationAction
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
