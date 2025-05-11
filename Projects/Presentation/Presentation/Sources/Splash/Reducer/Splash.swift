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
   
    
    @Shared(.inMemory("UserEntity")) var userEntity: UserEntity = .shared
    var checkSessionJWTDTOModel: RefreshTokenDTOModel?
    var profileDTOModel: ProfileDTOModel?
    var aceessToken = UserDefaults.standard.string(forKey: "ACCESS_TOKEN") ?? ""
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
    
  }
  
  // MARK: - AsyncAction 비동기 처리 액션
  
  public enum AsyncAction: Equatable {
    case sessionCheckJWT
    case checkJwtResponse(Result<RefreshTokenDTOModel, CustomError>)
    case fetchUser
    case fetchUserResponse(Result<ProfileDTOModel, CustomError>)
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
  
  @Dependency(AuthUseCase.self) var authUseCase
  @Dependency(ProfileUseCase.self) var profileUseCase
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
    
  }
  
  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {
    case .sessionCheckJWT:
      return .run { [useEntity = state.userEntity] send in
        let acceesToken  = UserDefaults.standard.string(forKey: "ACCESS_TOKEN") ?? ""
        
        let checkJwtResult = await Result {
          try await authUseCase.sessionCheckJWT(token: acceesToken)
        }
        
        switch checkJwtResult {
        case .success(let checkJwtDTOData):
          if let checkJwtDTOData = checkJwtDTOData {
            await send(.async(.checkJwtResponse(.success(checkJwtDTOData))))
            await send(.async(.fetchUser))
          }
          
        case .failure(let error):
          await send(.async(.checkJwtResponse(.failure(.encodingError(error.localizedDescription)))))
          await send(.navigation(.presentLogin))
        }
        
      }
      
      
    case .checkJwtResponse(let result):
      switch result {
      case .success(let jwtDTOData):
        state.checkSessionJWTDTOModel = jwtDTOData
        UserDefaults.standard.set(jwtDTOData.data.accessToken, forKey: "ACCESS_TOKEN")
        
        state.$userEntity.withLock {
          $0.accessToken = jwtDTOData.data.accessToken
          $0.refreshToken = jwtDTOData.data.refreshToken
          $0.userEmail = jwtDTOData.data.user.email
          $0.userName = jwtDTOData.data.user.email
        }
        
      case .failure(let error):
        #logNetwork("jwt check 실패", error.localizedDescription)
      }
      return .none
      
      
    case .fetchUser:
      return .run { send in
        let profileResult = await Result {
          try await profileUseCase.getProfile()
        }
        
        switch profileResult {
        case .success(let profileDTOData):
          if let profileDTOData = profileDTOData {
            await send(.async(.fetchUserResponse(.success(profileDTOData))))
            
            if profileDTOData.data.isStaff == true {
              await send(.navigation(.presentCoreMember))
            } else {
              await send(.navigation(.presentMember))
            }
          }
        case .failure(let error):
          await send(.async(.fetchUserResponse(.failure(CustomError.firestoreError(error.localizedDescription)))))
          await send(.navigation(.presentLogin))
          
        }
      }
      .debounce(id: SplashCancel(), for: 0.3, scheduler: mainQueue)
      
    case .fetchUserResponse(let result):
      switch result {
      case .success(let profileDTOData):
        state.profileDTOModel = profileDTOData
        state.$userEntity.withLock{
          $0.userName = profileDTOData.data.name
        }
      case .failure(let error):
        #logError("유저 정보 가져오기", error.localizedDescription)
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
    case .presentLogin:
      return .none
      
    case .presentCoreMember:
      return .none
      
    case .presentMember:
      return .none
    }
  }
}
