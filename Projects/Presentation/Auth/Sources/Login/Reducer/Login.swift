//
//  Login.swift
//  Presentation
//
//  Created by Wonji Suh  on 10/29/24.
//

import Foundation

import Core
import Utill
import Entity

import AsyncMoya
import AuthenticationServices
import ComposableArchitecture

@Reducer
public struct Login {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    var nonce: String = ""
    var appleAccessToken: String = ""
    var appleAuthCode: String = ""
    var appleLoginFullName: ASAuthorizationAppleIDCredential? = nil
    var oAuthResponseModel: OAuthResponseModel? = nil
    @Shared(.inMemory("Member")) var userSignUpMember: Member = .init()
    var userMember: UserDTOMember? = nil
    @Shared(.appStorage("UserEmail")) var userEmail: String = ""
    @Shared(.appStorage("AccessToken")) var accessToken: String = ""
    
    @Shared var userEntity: UserEntity
    var signUpModel: SignUpModel?
    var checkEmailModel: CheckEmailModel?
    var loginEntity: LoginEntity?
    var profileModel: ProfileResponseModel?
    
    public init(
      userEntity: UserEntity = .init()
    ) {
      self._userEntity = Shared(wrappedValue: userEntity, .inMemory("UserEntity"))
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
    case signInWithSocial(social: SocialType)
  }
  
  nonisolated enum CancelID: Hashable {
    case googleOAuth
    case appleOAuth
  }
  
  // MARK: - AsyncAction 비동기 처리 액션
  
  public enum AsyncAction {
    case prepareAppleRequest(ASAuthorizationAppleIDRequest)
    case appleLogin(Result<ASAuthorization, Error>, nonce: String)
    case login(socialType: SocialType)
  }
  
  // MARK: - 앱내에서 사용하는 액션
  public enum InnerAction {
    case appleResponse(Result<ASAuthorization, Error>)
    case loginResponse(Result<LoginEntity, AuthError>)
  }
  
  // MARK: - NavigationAction
  
  public enum NavigationAction: Equatable {
    case presentSignUpInviteView
    case presentCoreMemberMain
    case presentMemberMain
  }
  
  @Dependency(\.oAuthUseCase) var oAuthUseCase
  @Dependency(\.authUseCase) var authUseCase
  @Dependency(\.signUpUseCase) var signUpUseCase
  @Dependency(\.profileUseCase) var profileUseCase
  @Dependency(\.appleManger) var appleLoginManger
  @Dependency(\.unifiedOAuthUseCase) var unifiedOAuthUseCase
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
      case .signInWithSocial(let social):
        return .send(.async(.login(socialType: social)))
    }
  }
  
  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {
      case .prepareAppleRequest(let request):
        let nonce = appleLoginManger.prepare(request)
        state.nonce = nonce
        return .none
        
      case .appleLogin(let result, let nonce):
        return .run { send in
          guard
            case .success(let auth) = result,
            let credential = auth.credential as? ASAuthorizationAppleIDCredential,
            !nonce.isEmpty
          else {
            await send(.inner(.loginResponse(.failure(.invalidCredential("Apple 인증 정보가 없습니다")))))
            return
          }

          await send(.inner(.appleResponse(.success(auth))))
          try await clock.sleep(for: .seconds(0.4))
          await send(.async(.login(socialType: .apple)))
        }
        .cancellable(id: CancelID.appleOAuth)
        
      case .login(let socialType):
        return .run { [
          useEntity = state.userEntity,
          appleCredential = state.appleLoginFullName,
          nonce = state.nonce
        ] send in
          let outcome = await unifiedOAuthUseCase.processOAuthFlow(
            with: socialType,
            appleCredential: appleCredential,
            nonce: nonce,
            googleToken: useEntity.userEmail
          )
          return await send(.inner(.loginResponse(outcome)))
        }
        .cancellable(id: socialType == .apple ? CancelID.appleOAuth : CancelID.googleOAuth)
        
    }
    
  }
  
  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {
      case .appleResponse(let data):
        switch data {
          case .success(let authResult):
            switch authResult.credential {
              case let appleIDCredential as ASAuthorizationAppleIDCredential:
                guard let tokenData = appleIDCredential.identityToken,
                      let identityToken = String(data: tokenData, encoding: .utf8),
                      let _ = appleIDCredential.authorizationCode
                else {
                  #logError("Identity token is missing")
                  return .none
                }
                state.appleAccessToken = identityToken
                state.appleLoginFullName = appleIDCredential
                
                let email = UserDefaults.standard.string(forKey: "UserEmail") ?? ""
                let uid = UserDefaults.standard.string(forKey: "UserUID") ?? ""
                state.$userEntity.withLock {
                  $0.userEmail = email
                  $0.userUid = uid
                }
              default:
                break
            }
          case .failure(let error):
            #logError("애플로그인 에러", error)
        }
        return .none
        
      case .loginResponse(let result):
        switch result {
          case .success(let loginEntity):
            state.loginEntity = loginEntity
            UserDefaults.standard.set(loginEntity.token.accessToken, forKey: "ACCESS_TOKEN")
            state.$accessToken.withLock {$0 = loginEntity.token.accessToken}
            state.$userEntity.withLock {
              $0.userName = loginEntity.name
              $0.accessToken = loginEntity.token.accessToken
              $0.refreshToken = loginEntity.token.refreshToken
            }

            if loginEntity.isNewUser  {
              return .send(.navigation(.presentSignUpInviteView))
            } else {
              return .send(.navigation(.presentCoreMemberMain))
            }

          case .failure(let error):
            #logNetwork("로그인 실패", error.localizedDescription)

            return .none
        }
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
