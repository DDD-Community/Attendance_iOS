//
//  Login.swift
//  Presentation
//
//  Created by Wonji Suh  on 10/29/24.
//

import Foundation

import Networkings
import Utill

import AsyncMoya
import AuthenticationServices
import ComposableArchitecture

@Reducer
public struct Login {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    public init() {}
    
    var nonce: String = ""
    var appleAccessToken: String = ""
    var appleAuthCode: String = ""
    var appleLoginFullName: ASAuthorizationAppleIDCredential? = nil
    var oAuthResponseModel: OAuthResponseDTOModel? = nil
    @Shared(.inMemory("Member")) var userSignUpMember: Member = .init()
    var userMember: UserDTOMember? = nil
    @Shared(.appStorage("UserEmail")) var userEmail: String = ""
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
  
  struct LoginID: Hashable {}
  
  // MARK: - AsyncAction 비동기 처리 액션
  
  public enum AsyncAction {
    case appleLogin(Result<ASAuthorization, Error>, nonce: String)
    case appleRespose(Result<ASAuthorization, Error>)
    case googleLogin
    case oAuthResponse(Result<OAuthResponseDTOModel, CustomError>)
    case fetchUser
    case fetchUserResponse(Result<UserDTOMember, CustomError>)
  }
  
  // MARK: - 앱내에서 사용하는 액션
  public enum InnerAction: Equatable {
    
  }
  
  // MARK: - NavigationAction
  
  public enum NavigationAction: Equatable {
    case presentSignUpInviteView
    case presentCoreMemberMain
    case presentMemberMain
  }
  
  @Dependency(OAuthUseCase.self) var oAuthUseCase
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
        
      case .async(let AsyncAction):
        return handleAsyncAction(state: &state, action: AsyncAction)
        
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
    case .appleLogin(let authData, let nonce):
      return .run { send in
        do {
          let result = try await oAuthUseCase.handleAppleLogin(authData, nonce: nonce)
          await send(.async(.appleRespose(.success(result))))
          try await clock.sleep(for: .seconds(0.4))
          await send(.async(.fetchUser))
        } catch {
          #logDebug("애플 로그인 에러", error.localizedDescription)
        }
      }
      .debounce(id: LoginID(), for: 0.1, scheduler: mainQueue)
      
    case .appleRespose(let data):
      switch data {
      case .success(let authResult):
        switch authResult.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
          guard let tokenData = appleIDCredential.identityToken,
                let identityToken = String(data: tokenData, encoding: .utf8),
                let authorizationCode = appleIDCredential.authorizationCode
          else {
            #logError("Identity token is missing")
            return .none
          }
          state.appleAccessToken = identityToken
          state.appleLoginFullName = appleIDCredential
          state.userSignUpMember.email = appleIDCredential.email ?? ""
          let email = UserDefaults.standard.string(forKey: "UserEmail") ?? ""
          let uid = UserDefaults.standard.string(forKey: "UserUID") ?? ""
          state.userSignUpMember.email = email
          state.userSignUpMember.uid = uid
          state.userEmail = email
        default:
          break
        }
      case .failure(let error):
        #logError("애플로그인 에러", error)
      }
      return .none
      
    case .googleLogin:
      return .run { send in
        let googleLoginResult = await Result {
          try await oAuthUseCase.googleLogin()
        }
        
        switch googleLoginResult {
        case .success(let googleLoginData):
          if let googleLoginData = googleLoginData {
            await send(.async(.oAuthResponse(.success(googleLoginData))))
            await send(.async(.fetchUser))
          }
        case .failure(let error):
          await send(.async(.oAuthResponse(.failure(CustomError.firestoreError("구글 로그인 실패 \(error.localizedDescription)")))))
        }
      }
      .debounce(id: LoginID(), for: 0.1, scheduler: mainQueue)
      
    case .oAuthResponse(let result):
      switch result {
      case .success(let resultData):
        state.oAuthResponseModel = resultData
        state.userSignUpMember.email = resultData.email
        state.userSignUpMember.uid = resultData.uid
      case .failure(let error):
        #logError("소셜 로그인 실패", error.localizedDescription)
      }
      return .none
      
    case .fetchUser:
      return .run { [userMember = state.userSignUpMember] send in
        let fetchUserResult = await Result {
          try await authUseCase.fetchUser(uid: userMember.email)
        }
        
        switch fetchUserResult {
        case .success(let fetchUserData):
          if let fetchUserData = fetchUserData {
            await send(.async(.fetchUserResponse(.success(fetchUserData))))
            
            if fetchUserData.email != "" {
              if fetchUserData.isAdmin == true {
                await send(.navigation(.presentCoreMemberMain))
              } else {
                await send(.navigation(.presentMemberMain))
              }
            } else {
              await send(.navigation(.presentSignUpInviteView))
            }
          }
        case .failure(let error):
          await send(.async(.fetchUserResponse(.failure(CustomError.firestoreError(error.localizedDescription)))))
          await send(.navigation(.presentSignUpInviteView))
        }
      }
      
    case .fetchUserResponse(let result):
      switch result {
      case .success(let userDtoMemberData):
        state.userMember = userDtoMemberData
        let email = state.userMember?.email ?? ""
        state.userEmail = email
        
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
    case .presentSignUpInviteView:
      return .none
      
    case .presentCoreMemberMain:
      return .none
      
    case .presentMemberMain:
      return .none
    }
  }
}
