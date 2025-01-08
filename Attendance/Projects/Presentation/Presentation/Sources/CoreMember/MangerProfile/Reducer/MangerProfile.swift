//
//  MangerProfile.swift
//  DDDAttendance
//
//  Created by 서원지 on 7/17/24.
//

import Foundation

import DesignSystem
import Model
import Networkings
import Service
import Utill

import AsyncMoya
import ComposableArchitecture
import FirebaseAuth
import KeychainAccess

@Reducer
public struct MangerProfile {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    var user: User? =  nil
    var isLoading: Bool = false
    var mangeProfileName: String = "의 프로필"
    var mangerProfileRoleType: String = "직군"
    var mangerProfileManging: String = "담당 업무"
    var mangerProfileGeneration: String = "소속 기수"
    var logoutText: String = "로그아웃"
    
    @Shared(.appStorage("UserEmail")) var userEmail: String = ""
    var userMember: UserDTOMember? = nil
    public init() {}
  }
  
  public enum Action: ViewAction, FeatureAction, BindableAction {
    case binding(BindingAction<State>)
    case view(View)
    case async(AsyncAction)
    case inner(InnerAction)
    case navigation(NavigationAction)
    
  }
  
  // MARK: - View action
  
  public enum View {
    
  }
  
  // MARK: - 비동기 처리 액션
  
  public enum AsyncAction: Equatable {
    case signOut
    case fetchUserDataResponse(Result<User, CustomError>)
    case fetchUser
    case fetchUserResponse(Result<UserDTOMember, CustomError>)
  }
  
  // MARK: - 앱내에서 사용하는 액션
  
  public enum InnerAction: Equatable {
    
  }
  
  // MARK: - 네비게이션 연결 액션
  
  public enum NavigationAction: Equatable {
    case tapLogOut
    case presentCreatByApp
  }
  
  @Dependency(FireStoreUseCase.self) var fireStoreUseCase
  @Dependency(AuthUseCase.self) var authUseCase
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding(_):
        return .none
        
      // MARK: - ViewAction
        
      case .view(let viewAction):
        return handleViewAction(state: &state, action: viewAction)
        
      // MARK: - AsyncAction
        
      case .async(let asyncAction):
        return handleAsyncAction(state: &state, action: asyncAction)
        
      // MARK: - InnerAction
        
      case .inner(let innerAction):
        return handleInnerAction(state: &state, action: innerAction)
        
      // MARK: - NavigationAction
        
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
            
          }
        case .failure(let error):
          await send(.async(.fetchUserResponse(.failure(CustomError.firestoreError(error.localizedDescription)))))
        }
      }
      
    case .fetchUserResponse(let result):
      switch result {
      case .success(let userDtoMemberData):
        state.userMember = userDtoMemberData
        state.userEmail = userDtoMemberData.email
        
      case .failure(let error):
        #logError("유저 정보 가쟈오기", error.localizedDescription)
      }
      return .none
      
    case .signOut:
      return .run { send  in
        let fetchUserResult = await Result {
          try await fireStoreUseCase.getUserLogOut()
        }
        
        switch fetchUserResult {
          
        case let .success(fetchUserResult):
          guard let fetchUserResult = fetchUserResult else {return}
          await send(.async(.fetchUserDataResponse(.success(fetchUserResult))))
          
        case let .failure(error):
          await send(.async(.fetchUserDataResponse(.failure(CustomError.map(error)))))
        }
      }
      
    case let .fetchUserDataResponse(fetchUser):
      switch fetchUser {
      case let .success(fetchUser):
        state.user = fetchUser
        #logDebug("fetching data", fetchUser.uid)
      case let .failure(error):
        #logError("Error fetching User", error)
        state.user = nil
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
    case .tapLogOut:
      state.userEmail = ""
      return .run {  send in
        await send(.async(.signOut))
      }
      
    case .presentCreatByApp:
      return .none
    }
  }
}

