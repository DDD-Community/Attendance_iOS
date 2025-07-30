//
//  Login.swift
//  Presentation
//
//  Created by Wonji Suh  on 10/29/24.
//

import Foundation

import Core
import Utill

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
    var loginModel: LoginModel?
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

  }

  struct LoginID: Hashable {}

  // MARK: - AsyncAction 비동기 처리 액션

  public enum AsyncAction {
    case appleLogin(Result<ASAuthorization, Error>, nonce: String)
    case googleLogin
    case signUpUser
    case checkEmail
    case loginUser
    case fetchUser
  }

  // MARK: - 앱내에서 사용하는 액션
  public enum InnerAction {
    case appleRespose(Result<ASAuthorization, Error>)
    case oAuthResponse(Result<OAuthResponseModel, CustomError>)
    case signUpUserResponse(Result<SignUpModel, CustomError>)
    case checkEmailResponse(Result<CheckEmailModel, CustomError>)
    case loginUserResponse(Result<LoginModel, CustomError>)
    case fetchUserResponse(Result<ProfileResponseModel, CustomError>)
  }

  // MARK: - NavigationAction

  public enum NavigationAction: Equatable {
    case presentSignUpInviteView
    case presentCoreMemberMain
    case presentMemberMain
  }

  @Dependency(OAuthUseCaseImpl.self) var oAuthUseCase
  @Dependency(AuthUseCaseImpl.self) var authUseCase
  @Dependency(SignUpUseCaseImpl.self) var signUpUseCase
  @Dependency(ProfileUseCaseImpl.self) var profileUseCase
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
          await send(.inner(.appleRespose(.success(result))))
          try await clock.sleep(for: .seconds(0.4))
          
          await send(.async(.checkEmail))
        } catch {
          #logDebug("애플 로그인 에러", error.localizedDescription)
        }
      }

    case .googleLogin:
      return .run { send in
        let googleLoginResult = await Result {
          try await oAuthUseCase.googleLogin()
        }
        
        switch googleLoginResult {
        case .success(let googleLoginData):
          if let googleLoginData = googleLoginData {
            await send(.inner(.oAuthResponse(.success(googleLoginData))))
            await send(.async(.checkEmail))
          }
        case .failure(let error):
          await send(.inner(.oAuthResponse(.failure(CustomError.firestoreError("구글 로그인 실패 \(error.localizedDescription)")))))
        }
      }
      .debounce(id: LoginID(), for: 0.1, scheduler: mainQueue)

      
    case .signUpUser:
      return .run { [userEntity = state.userEntity] send in
        let registerUserResult = await Result {
          try await signUpUseCase.registerAccount(
            email: userEntity.userEmail,
            password: userEntity.userUid
          )
        }
        
        switch registerUserResult {
        case .success(let registerUserData):
          if let registerUserData = registerUserData {
            await send(.inner(.signUpUserResponse(.success(registerUserData))))

            if registerUserData.data.accessToken?.isEmpty != nil &&
                registerUserData.data.user != nil {
              await send(.navigation(.presentSignUpInviteView))
            }
          }
          
        case .failure(let error):
          await send(.inner(.signUpUserResponse(.failure(.encodingError("회원 가입 실패 \(error.localizedDescription)")))))
        }
      }

      
    case .checkEmail:
      return .run { [ useEntity = state.userEntity ] send in
        let checkEmailResult = await Result {
          try await signUpUseCase.checkEmail(email: useEntity.userEmail)
        }
        
        switch checkEmailResult {
        case .success(let checkEmailDTOData):
          if  let checkEmailDTOData = checkEmailDTOData {
            await send(.inner(.checkEmailResponse(.success(checkEmailDTOData))))

            if checkEmailDTOData.data.emailUsed == true {
              await send(.async(.loginUser))
            } else {
              await send(.async(.signUpUser))
            }
          }
          
        case .failure(let error):
          await send(.inner(.checkEmailResponse(.failure(.encodingError(error.localizedDescription)))))
        }
      }

    case .loginUser:
      return .run { [
        useEntity = state.userEntity
      ]  send in
        let loginResult = await Result {
          try await authUseCase.loginUser(email: useEntity.userEmail)
        }
        
        switch loginResult {
        case .success(let loginResultData):
          if  let loginResultData = loginResultData {
            await send(.inner(.loginUserResponse(.success(loginResultData))))

            if !loginResultData.data.accessToken.isEmpty {
              await send(.async(.fetchUser))
            }
          }
          
        case .failure(let error):
          await send(.inner(.loginUserResponse(.failure(.encodingError("로그인 실패 \(error.localizedDescription)")))))
        }
      }

      
    case .fetchUser:
      return .run { send in
        let profileDataResult = await Result {
          try await profileUseCase.getProfile()
        }
        
        switch profileDataResult {
        case .success(let profileDTOData):
          if let profileDTOData = profileDTOData {
            await send(.inner(.fetchUserResponse(.success(profileDTOData))))

            if profileDTOData.isStaff == true {
              await send(.navigation(.presentCoreMemberMain))
            } else if profileDTOData.crew == .notTeam && profileDTOData.team == .notTeam  {
              await send(.navigation(.presentSignUpInviteView))
            }
            else {
              await send(.navigation(.presentMemberMain))
            }
          }
          
        case .failure(let error):
          await send(.inner(.fetchUserResponse(.failure(.encodingError(error.localizedDescription)))))
        }
        
      }

    }
    
  }
  
  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {
    case .appleRespose(let data):
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

    case .oAuthResponse(let result):
      switch result {
      case .success(let resultData):
        state.oAuthResponseModel = resultData
        state.$userEntity.withLock{
          $0.userUid = resultData.uid
          $0.userEmail = resultData.email
        }
      case .failure(let error):
        #logError("소셜 로그인 실패", error.localizedDescription)
      }
      return .none

    case .signUpUserResponse(let result):
      switch result {
      case .success(let signUpModel):
        state.signUpModel = signUpModel
        UserDefaults.standard.set(signUpModel.data.accessToken, forKey: "ACCESS_TOKEN")
        state.$accessToken.withLock { $0 = signUpModel.data.accessToken ?? ""}
        state.$userEntity.withLock {
          $0.accessToken = signUpModel.data.accessToken ?? ""
          $0.refreshToken = signUpModel.data.refreshToken ?? ""
        }
        
      case .failure(let error):
        #logNetwork("회원가입 실패", error.localizedDescription)
      }
      return .none

    case .checkEmailResponse(let result):
      switch result {
      case .success(let checkEmailDTO):
        state.checkEmailModel = checkEmailDTO

      case .failure(let error):
        #logNetwork("이메일 중복 확인 실패", error.localizedDescription)
      }
      return .none

    case .loginUserResponse(let result):
      switch result {
      case .success(let loginDTOData):
        state.loginModel = loginDTOData
        UserDefaults.standard.set(loginDTOData.data.accessToken, forKey: "ACCESS_TOKEN")
        state.$accessToken.withLock {$0 = loginDTOData.data.accessToken}
        state.$userEntity.withLock {
          $0.userEmail = loginDTOData.data.email
          $0.accessToken = loginDTOData.data.accessToken
          $0.refreshToken = loginDTOData.data.refreshToken
        }
        
        
      case .failure(let error):
        #logNetwork("로그인 실패", error.localizedDescription)
      }
      return .none

    case .fetchUserResponse(let result):
      switch result {
      case .success(let profileDTOData):
        state.profileModel = profileDTOData

        state.$userEntity.withLock {
          $0.inviteCodeId = profileDTOData.inviteCodeID
        }
        
      case .failure(let error):
        #logNetwork("프로필 조회 실패", error.localizedDescription)
      }
      return .none
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
