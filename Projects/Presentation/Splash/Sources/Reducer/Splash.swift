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

import ComposableArchitecture
import FirebaseAuth
import LogMacro

@Reducer
public struct Splash {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {

    @Shared(.inMemory("UserEntity")) var userEntity: UserEntity = .shared

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
    case checkToken
  }
  
  // MARK: - 앱내에서 사용하는 액션
  
  public enum InnerAction: Equatable {

  }
  
  // MARK: - NavigationAction
  
  public enum NavigationAction: Equatable {
    case presentLogin
    case presentCoreMember
    case presentMember
  }
  
  fileprivate struct SplashCancel: Hashable {}
  
  @Dependency(\.authUseCase) var authUseCase
  @Dependency(\.profileUseCase) var profileUseCase
  @Dependency(\.keychainManager) var keychainManager
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
  
  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
      case .onAppear:
        return .send(.async(.checkToken))
    }

  }
  
  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {
    case .checkToken:
      return .run { send in
        // 토큰 확인
        guard let accessToken = keychainManager.accessToken(),
              !accessToken.isEmpty else {
          await send(.navigation(.presentLogin))
          return
        }

        // 만료 체크
        guard !JWTUtils.isExpired(accessToken) else {
          await send(.navigation(.presentLogin))
          return
        }
        
        // type에 따른 화면 이동
        switch JWTUtils.getUserType(from: accessToken)?.lowercased() {
        case "manager", "staff":
          await send(.navigation(.presentCoreMember))
        case "member":
          await send(.navigation(.presentMember))
        default:
          await send(.navigation(.presentLogin))
        }
      }
    }
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
      
    case .presentCoreMember:
      return .none
      
    case .presentMember:
      return .none
    }
  }
}
