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
    case fetchProfile
  }
  
  // MARK: - 앱내에서 사용하는 액션
  
  public enum InnerAction: Equatable {
    case fetchUserResponse(Result<ProfileEntity, ProfileError>)
  }
  
  // MARK: - NavigationAction
  
  public enum NavigationAction: Equatable {
    case presentLogin
    case presentStaff
    case presentMember
  }
  
  nonisolated enum CancelID: Hashable {
    case fetchProfile
  }

  @Dependency(\.profileUseCase) var profileUseCase

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
        return .send(.async(.fetchProfile))
    }

  }

  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {
    case .fetchProfile:
        return .run { send in
          let profileResult = await Result {
            try await profileUseCase.getProfile()
          }
            .mapError(ProfileError.from)
          return await send(.inner(.fetchUserResponse(profileResult)))
        }
    }
  }

  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {
      case .fetchUserResponse(let result):
        switch result {
          case .success(let profileData):
            state.profileModel = profileData

            if state.profileModel?.role == .manager {
              return .send(.navigation(.presentStaff))
            } else {
              return .send(.navigation(.presentMember))
            }

          case .failure(let error):
            #logDebug("네트워크 통신 에러 ", error.localizedDescription)
            return .send(.navigation(.presentLogin))

        }
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
