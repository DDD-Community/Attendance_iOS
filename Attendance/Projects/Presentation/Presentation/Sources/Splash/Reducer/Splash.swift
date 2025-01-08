//
//  Splash.swift
//  Presentation
//
//  Created by Wonji Suh  on 10/29/24.
//

import Foundation

import Networkings
import Utill

import ComposableArchitecture
import FirebaseAuth

@Reducer
public struct Splash {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    public init() {}
    @Shared(.appStorage("UserEmail")) var userEmail: String = ""
    @Shared(.appStorage("UserUID")) var userUid: String = ""
    var userMember: UserDTOMember? = nil
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
    
  }
  
  // MARK: - AsyncAction 비동기 처리 액션
  
  public enum AsyncAction: Equatable {
    case fetchUser
    case fetchUserResponse(Result<UserDTOMember, CustomError>)
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
  
  @Dependency(AuthUseCase.self) var authUseCase
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
  
    }
  }
    
  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {
      
    case .fetchUser:
      return .run { [userEmail = state.userEmail] send in
        let fetchUserResult = await Result {
          try await authUseCase.fetchUser(uid: userEmail)
        }
        
        switch fetchUserResult {
        case .success(let fetchUserData):
          if let fetchUserData = fetchUserData {
            await send(.async(.fetchUserResponse(.success(fetchUserData))))
            
            if fetchUserData.email != "" {
              if fetchUserData.isAdmin == true {
                await send(.navigation(.presentCoreMember))
              } else {
                await send(.navigation(.presentMember))
              }
            }
          }
        case .failure(let error):
          await send(.async(.fetchUserResponse(.failure(CustomError.firestoreError(error.localizedDescription)))))
          await send(.navigation(.presentLogin))
          
        }
      }
      
    case .fetchUserResponse(let result):
      switch result {
      case .success(let userDtoMemberData):
        state.userMember = userDtoMemberData
        let email = state.userMember?.email ?? ""
        state.userUid = userDtoMemberData.uid
        state.userEmail = userDtoMemberData.email
      case .failure(let error):
        #logError("유저 정보 가쟈오기", error.localizedDescription)
      }
      return .none
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
