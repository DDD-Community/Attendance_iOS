//
//  ManagerProfile.swift
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
public struct ManagerProfile {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    var user: User? =  nil
    var isLoading: Bool = false
    var managerProfileName: String = "의 프로필"
    var managerProfileRoleType: String = "직군"
    var memberSelectTeam: String = "소속 팀"
    var managerProfileManaging: String = "담당 업무"
    var managerProfileGeneration: String = "소속 기수"
    var logoutText: String = "로그아웃"
    
    @Shared(.appStorage("UserEmail")) var userEmail: String = ""
    @Shared(.appStorage("AccessToken")) var accessToken: String = ""
    
    var userMember: UserDTOMember? = nil
    var profileDTOModel: ProfileDTOModel?
    
    @Presents var destination: Destination.State?
    public init() {}
  }
  
  @Reducer(state: .equatable)
  public enum Destination {
    case createApp(CreateApp)
  }
  
  public enum Action: ViewAction, FeatureAction, BindableAction {
    case destination(PresentationAction<Destination.Action>)
    case binding(BindingAction<State>)
    case view(View)
    case async(AsyncAction)
    case inner(InnerAction)
    case navigation(NavigationAction)
    
  }
  
  // MARK: - View action
  
  public enum View {
    case startLoading
    case stopLoading
    case appearModal
    case closeModal
  }
  
  // MARK: - 비동기 처리 액션
  
  public enum AsyncAction: Equatable {
    case signOut
    case fetchUserDataResponse(Result<User, CustomError>)
    case fetchUser
    case fetchUserResponse(Result<ProfileDTOModel, CustomError>)
  }
  
  // MARK: - 앱내에서 사용하는 액션
  
  public enum InnerAction: Equatable {
    
  }
  
  // MARK: - 네비게이션 연결 액션
  
  public enum NavigationAction: Equatable {
    case presentLogOut
    case presentCreatByApp
  }
  
  fileprivate struct MangerProfileCancel: Hashable {}
  
  @Dependency(FireStoreUseCase.self) var fireStoreUseCase
  @Dependency(AuthUseCase.self) var authUseCase
  @Dependency(ProfileUseCase.self) var profileUseCase
  @Dependency(\.mainQueue) var mainQueue
  @Dependency(\.continuousClock) var clock
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding(_):
        return .none
        
      case .destination(_):
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
    .ifLet(\.$destination, action: \.destination)
  }
  
  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
    case .startLoading:
      state.isLoading = true
      return .none
      
    case .stopLoading:
      state.isLoading = false
      return .none
      
    case .appearModal:
      state.destination = .createApp(.init())
      return .none
      
    case .closeModal:
      state.destination = nil
      return .none
    }
  }
  
  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {
      
    case .fetchUser:
      return .run { send in
        let fetchUserResult = await Result {
          try await profileUseCase.getProfile()
        }
        
        switch fetchUserResult {
        case .success(let profileUserDTOData):
          if let profileUserDTOData = profileUserDTOData {
            await send(.view(.startLoading))
            
            try await clock.sleep(for: .seconds(1.5))
            
            await send(.view(.stopLoading))
            
            await send(.async(.fetchUserResponse(.success(profileUserDTOData))))
            
          }
        case .failure(let error):
          await send(.async(.fetchUserResponse(.failure(CustomError.firestoreError(error.localizedDescription)))))
        }
      }
      .debounce(id: MangerProfileCancel(), for: 0.01, scheduler: mainQueue)
      
    case .fetchUserResponse(let result):
      switch result {
      case .success(let profileDTOData):
        state.profileDTOModel = profileDTOData
        
      case .failure(let error):
        #logError("유저 정보 가져오기", error.localizedDescription)
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
    
  }
  
  private func handleNavigationAction(
    state: inout State,
    action: NavigationAction
  ) -> Effect<Action> {
    switch action {
    case .presentLogOut:
      state.$accessToken.withLock { $0 = ""}
      return .run {  send in
        try await clock.sleep(for: .seconds(2))
        await send(.async(.signOut))
      }
      
    case .presentCreatByApp:
      return .none
    }
  }
}

