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
import DesignSystem

@Reducer
public struct Login {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    var nonce: String = ""
    var appleAccessToken: String = ""
    var appleLoginFullName: ASAuthorizationAppleIDCredential? = nil

    @Shared var userSession: UserSession
    var loginEntity: LoginEntity?
    var currentSocialType: SocialType?
    
    public init(
      userSession: UserSession = .empty
    ) {
      self._userSession = Shared(wrappedValue: userSession, .inMemory("UserSession"))
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
    case loginResponse(Result<LoginEntity, AuthError>)
  }
  
  // MARK: - NavigationAction
  public enum NavigationAction: Equatable {
    case presentSignUpInviteView
    case presentCoreMemberMain
    case presentMemberMain
  }

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
        state.currentSocialType = .apple
        return .run { send in
          guard
            case .success(let auth) = result,
            let credential = auth.credential as? ASAuthorizationAppleIDCredential,
            !nonce.isEmpty
          else {
            await send(.inner(.loginResponse(.failure(.invalidCredential("Apple 인증 정보가 없습니다")))))
            return
          }

          // Apple credential을 직접 처리하여 로그인 완료
          let outcome = await unifiedOAuthUseCase.processOAuthFlow(
            with: .apple,
            appleCredential: credential,
            nonce: nonce,
            googleToken: nil
          )
          await send(.inner(.loginResponse(outcome)))
        }
        .cancellable(id: CancelID.appleOAuth)
        
      case .login(let socialType):
        state.currentSocialType = socialType
        state.$userSession.withLock { $0.provider = socialType }
        return .run { [
          useEntity = state.userSession,
          appleCredential = state.appleLoginFullName,
          nonce = state.nonce
        ] send in
          let outcome = await unifiedOAuthUseCase.processOAuthFlow(
            with: socialType,
            appleCredential: appleCredential,
            nonce: nonce,
            googleToken: useEntity.token
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
      case .loginResponse(let result):
        switch result {
          case .success(let loginEntity):
            state.loginEntity = loginEntity

            if loginEntity.isNewUser  {
              return .send(.navigation(.presentSignUpInviteView))
            } else {
              return .send(.navigation(.presentCoreMemberMain))
            }

          case .failure(let error):
            #logNetwork("로그인 실패", error.localizedDescription)
            let socialType = state.currentSocialType
            return .run { _ in
                await MainActor.run {
                    let errorMessage: String
                    switch socialType {
                    case .apple:
                        errorMessage = "Apple 인증에 실패하였습니다."
                    case .google:
                        errorMessage = "구글 인증에 실패하였습니다."
                    default:
                        errorMessage = "인증에 실패했어요. 다시 시도해주세요."
                    }
                    ToastManager.shared.showError(errorMessage)
                }
            }
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
