//
//  Login.swift
//  Presentation
//
//  Created by Wonji Suh  on 10/29/24.
//

import Foundation
import ComposableArchitecture

import Utill
import Networkings
import AuthenticationServices
import AsyncMoya


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
    var oAuthResponseModel: OAuthResponseModel? = nil
  }
  
  public enum Action: ViewAction, BindableAction, FeatureAction {
    case binding(BindingAction<State>)
    case view(View)
    case async(AsyncAction)
    case inner(InnerAction)
    case navigation(NavigationAction)
  }
  
  //MARK: - ViewAction
  @CasePathable
  public enum View {
    
  }
  
  struct LoginID: Hashable {}
  
  
  //MARK: - AsyncAction 비동기 처리 액션
  public enum AsyncAction {
    case appleLogin(Result<ASAuthorization, Error>, nonce: String)
    case appleRespose(Result<ASAuthorization, Error>)
    case googleLogin
    case oAuthResponse(Result<OAuthResponseModel, CustomError>)
  }
  
  //MARK: - 앱내에서 사용하는 액션
  public enum InnerAction: Equatable {
    
  }
  
  //MARK: - NavigationAction
  public enum NavigationAction: Equatable {
    
    
  }
  
  @Dependency(OAuthUseCase.self) var oAuthUseCase
  @Dependency(\.continuousClock) var clock
  @Dependency(\.mainQueue) var mainQueue
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding(_):
        return .none
        
        
      case .view(let View):
        switch View {
          
        }
        
      case .async(let AsyncAction):
        return handleAsyncAction(state: &state, action: AsyncAction)
        
      case .inner(let InnerAction):
        switch InnerAction {
          
        }
        
      case .navigation(let NavigationAction):
        switch NavigationAction {
          
        }
      }
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
          try await clock.sleep(for: .seconds(0.03))
        } catch {
          Log.debug("애플 로그인 에러", error.localizedDescription)
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
      case .failure(let error):
        #logError("소셜 로그인 실패", error.localizedDescription)
      }
      return .none
    }
  }
    
}
