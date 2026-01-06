//
//  Splash.swift
//  Presentation
//
//  Created by Wonji Suh  on 10/29/24.
//

import Foundation

import Shareds
import Utill
import UseCase
import Entity

import ComposableArchitecture
import FirebaseAuth
import LogMacro

@Reducer
public struct Splash {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {

    @Shared(.inMemory("UserEntity")) var userEntity: UserEntity = .shared
    @Shared(.appStorage("staffRole")) var staffRole: Staff?
    var profileModel: ProfileEntity?

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
  
  // MARK: - ViewAction
  
  @CasePathable
  public enum View {
    case onAppear

  }
  
  // MARK: - AsyncAction 비동기 처리 액션
  
  public enum AsyncAction: Equatable {
  }
  
  // MARK: - 앱내에서 사용하는 액션
  
  public enum InnerAction: Equatable {
  }
  
  // MARK: - NavigationAction
  
  public enum NavigationAction: Equatable {
    case presentLogin
    case presentStaff
    case presentMember
  }
  
  nonisolated enum CancelID: Hashable {

  }


  @Dependency(\.continuousClock) var clock
  @Dependency(\.mainQueue) var mainQueue
  
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
}

extension Splash {
  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
      case .onAppear:
        return .run { [
          staffRole = state.staffRole
        ] send in
          if staffRole == .manager {
            return await send(.navigation(.presentStaff))
          } else if staffRole == .member {
            return await send(.navigation(.presentMember))
          } else {
            return await send(.navigation(.presentLogin))
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
    switch action {
     
    }
  }

  private func handleNavigationAction(
    state: inout State,
    action: NavigationAction
  ) -> Effect<Action> {
    switch action {
    case .presentLogin:
      return .none

    case .presentStaff:
      return .none

    case .presentMember:
      return .none
    }
  }
}
