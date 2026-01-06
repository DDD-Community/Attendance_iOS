//
//  Splash.swift
//  Presentation
//
//  Created by Wonji Suh  on 10/29/24.
//

import Foundation

import Shareds
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
//    var loginModel: LoginModel?
    var profileDTOModel: ProfileResponseModel?
    @Shared(.appStorage("AccessToken")) var accessToken: String = ""
    @Shared(.appStorage("UserEmail")) var userEmail: String = ""

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
//    case autoLogin
    case fetchUser
  }
  
  // MARK: - 앱내에서 사용하는 액션
  
  public enum InnerAction: Equatable {
    case fetchUserResponse(Result<ProfileResponseModel, CustomError>)
//    case autoLoginResponse(Result<LoginModel?, CustomError>)
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
    case .fetchUser:
      return .run { send in
        let profileResult = await Result {
          try await profileUseCase.getProfile()
        }

        switch profileResult {
        case .success(let profileDTOData):
          if let profileDTOData = profileDTOData {
            await send(.inner(.fetchUserResponse(.success(profileDTOData))))

            if profileDTOData.isStaff == true {
              await send(.navigation(.presentCoreMember))
            } else if profileDTOData.role == .all {
              await send(.navigation(.presentLogin))
            } else {
              await send(.navigation(.presentMember))
            }
          }
        case .failure(let error):
          await send(.inner(.fetchUserResponse(.failure(CustomError.firestoreError(error.localizedDescription)))))
          await send(.navigation(.presentLogin))

        }
      }

//    case .autoLogin:
//      return .run { [userEmail = state.userEmail] send in
//        let email = UserDefaults.standard.string(forKey: "UserEmail") ?? ""
//        let loginResult = await Result {
//          try await authUseCase.loginUser(email: userEmail)
//        }
//
//        switch loginResult {
//        case .success(let loginModel):
//          if let loginModel = loginModel {
//            await send(.inner(.autoLoginResponse(.success(loginModel))))
//
//            if loginModel.code == 200 {
//              await send(.async(.fetchUser))
//            }
//          }
//
//        case .failure(let error):
//          await send(.inner(.autoLoginResponse(.failure(.encodingError(error.localizedDescription)))))
//          await send(.navigation(.presentLogin))
//        }
//      }
    }
  }

  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {
    case .fetchUserResponse(let result):
      switch result {
      case .success(let profileDTOData):
        state.profileDTOModel = profileDTOData
        state.$userEntity.withLock{
          $0.userName = profileDTOData.name
        }
      case .failure(let error):
        #logError("유저 정보 가져오기", error.localizedDescription)
      }
      return .none

//    case .autoLoginResponse(let result):
//      switch result {
//      case .success(let loginDTOData):
//        state.loginModel = loginDTOData
//        UserDefaults.standard.set(loginDTOData?.data.accessToken, forKey: "ACCESS_TOKEN")
//        state.$accessToken.withLock {$0 = loginDTOData?.data.accessToken ?? ""}
//        state.$userEntity.withLock {
//          $0.userEmail = loginDTOData?.data.email ?? ""
//          $0.accessToken = loginDTOData?.data.accessToken ?? ""
//          $0.refreshToken = loginDTOData?.data.refreshToken ?? ""
//        }
//
//
//      case .failure(let error):
//        #logNetwork("로그인 실패", error.localizedDescription)
//      }
//      return .none
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
