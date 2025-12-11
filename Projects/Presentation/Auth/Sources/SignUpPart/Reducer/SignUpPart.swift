//
//  SignUpPart.swift
//  Presentation
//
//  Created by Wonji Suh  on 11/3/24.
//

import Foundation

import Core
import Utill

import ComposableArchitecture

@Reducer
public struct SignUpPart {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    public init() {}
    
    var activeSelectPart: Bool = false
    var selectPart: SelectPart? = .all
    @Shared(.inMemory("UserEntity")) var userEntity: UserEntity = .shared
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
    case presentManaging
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
        // 동일한 파트 재선택 → 해제
        state.selectPart = nil
        state.$userEntity.withLock { $0.role = nil }
        state.activeSelectPart = false
        return .none
      }
      
      state.selectPart = selectPart
      state.$userEntity.withLock { $0.role = selectPart }
      state.activeSelectPart = true
      #logDebug("selectPart", state.userEntity.role)
      return .none
    }
  }
  
  private func handleNavigationAction(
    state: inout State,
    action: NavigationAction
  ) -> Effect<Action> {
    switch action {
    case .presentManaging:
      return .none
    case .presentSelectTeam:
      return .none
    case .presentNextStep:
      return .run { [isAdmin = state.userEntity.userRole] send in
        if isAdmin == .moderator {
          await send(.navigation(.presentManaging))
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
    
  }
  
  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    
  }
}
