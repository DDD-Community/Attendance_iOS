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
   
    
    var nonce: String = ""
    var appleAccessToken: String = ""
    var appleAuthCode: String = ""
    var appleLoginFullName: ASAuthorizationAppleIDCredential? = nil
    var oAuthResponseModel: OAuthResponseDTOModel? = nil
    @Shared(.inMemory("Member")) var userSignUpMember: Member = .init()
    var userMember: UserDTOMember? = nil
    @Shared(.appStorage("UserEmail")) var userEmail: String = ""
    @Shared(.appStorage("AccessToken")) var accessToken: String = ""
    
    @Shared var userEntity: UserEntity
    var signUpDTOModel: SignUpDTOModel?
    var checkEmailDTOModel: CheckEmailDTO?
    var loginDTOModel: LoginDTOModel?
    var profileDTOModel: ProfileDTOModel?
    
    
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
    case appleRespose(Result<ASAuthorization, Error>)
    case googleLogin
    case oAuthResponse(Result<OAuthResponseDTOModel, CustomError>)
    case registerUser
    case registerUserResponse(Result<SignUpDTOModel, CustomError>)
    case checkEmail
    case checkEmailResponse(Result<CheckEmailDTO, CustomError>)
    case loginUser
    case loginUserResponse(Result<LoginDTOModel, CustomError>)
    case fetchUser
    case fetchUserResponse(Result<ProfileDTOModel, CustomError>)
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
  @Dependency(SignUpUseCase.self) var signUpUseCase
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
          await send(.async(.appleRespose(.success(result))))
          try await clock.sleep(for: .seconds(0.4))
          
          await send(.async(.checkEmail))
        } catch {
          #logDebug("애플 로그인 에러", error.localizedDescription)
        }
      }
      
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
      
    case .googleLogin:
      return .run { send in
        let googleLoginResult = await Result {
          try await oAuthUseCase.googleLogin()
        }
        
        switch googleLoginResult {
        case .success(let googleLoginData):
          if let googleLoginData = googleLoginData {
            await send(.async(.oAuthResponse(.success(googleLoginData))))
            await send(.async(.checkEmail))
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
        state.$userEntity.withLock{
          $0.userUid = resultData.uid
          $0.userEmail = resultData.email
        }
      case .failure(let error):
        #logError("소셜 로그인 실패", error.localizedDescription)
      }
      return .none
      
    case .registerUser:
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
            await send(.async(.registerUserResponse(.success(registerUserData))))
            
            if !registerUserData.data.accessToken.isEmpty {
              await send(.navigation(.presentSignUpInviteView))
            }
          }
          
        case .failure(let error):
          await send(.async(.registerUserResponse(.failure(.encodingError("회원 가입 실패 \(error.localizedDescription)")))))
        }
      }
      
    case .registerUserResponse(let result):
      switch result {
      case .success(let registerDTO):
        UserDefaults.standard.set(registerDTO.data.accessToken, forKey: "ACCESS_TOKEN")
        state.$accessToken.withLock { $0 = registerDTO.data.accessToken}
        state.$userEntity.withLock {
          $0.accessToken = registerDTO.data.accessToken
          $0.refreshToken = registerDTO.data.refreshToken
        }
        
      case .failure(let error):
        #logNetwork("회원가입 실패", error.localizedDescription)
      }
      return .none
      
    case .checkEmail:
      return .run { [ useEntity = state.userEntity ] send in
        let checkEmailResult = await Result {
          try await signUpUseCase.checkEmail(email: useEntity.userEmail)
        }
        
        switch checkEmailResult {
        case .success(let checkEmailDTOData):
          if  let checkEmailDTOData = checkEmailDTOData {
            await send(.async(.checkEmailResponse(.success(checkEmailDTOData))))
            
            if checkEmailDTOData.data.emailUsed == true {
              await send(.async(.loginUser))
            } else {
              await send(.async(.registerUser))
              }
          }
          
        case .failure(let error):
          await send(.async(.checkEmailResponse(.failure(.encodingError(error.localizedDescription)))))
        }
      }
      
    case .checkEmailResponse(let result):
      switch result {
      case .success(let checkEmailDTO):
        state.checkEmailDTOModel = checkEmailDTO
        
      case .failure(let error):
        #logNetwork("이메일 중복 확인 실패", error.localizedDescription)
      }
      return .none
      
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
            await send(.async(.loginUserResponse(.success(loginResultData))))
            
            if !loginResultData.data.accessToken.isEmpty {
              await send(.async(.fetchUser))
            }
          }
          
        case .failure(let error):
          await send(.async(.loginUserResponse(.failure(.encodingError("로그인 실패 \(error.localizedDescription)")))))
        }
      }
      
    case .loginUserResponse(let result):
      switch result {
      case .success(let loginDTOData):
        state.loginDTOModel = loginDTOData
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
      
    case .fetchUser:
      return .run { send in
        let profileDataResult = await Result {
          try await profileUseCase.getProfile()
        }
        
        switch profileDataResult {
        case .success(let profileDTOData):
          if let profileDTOData = profileDTOData {
            await send(.async(.fetchUserResponse(.success(profileDTOData))))
            
            if profileDTOData.data.isStaff == true {
              await send(.navigation(.presentCoreMemberMain))
            } else {
              await send(.navigation(.presentMemberMain))
            }
          }
          
        case .failure(let error):
          await send(.async(.fetchUserResponse(.failure(.encodingError(error.localizedDescription)))))
        }
        
      }
      
    case .fetchUserResponse(let result):
      switch result {
      case .success(let profileDTOData):
        state.profileDTOModel = profileDTOData
        
        state.$userEntity.withLock {
          $0.inviteCodeId = profileDTOData.data.inviteCodeID
        }
        
      case .failure(let error):
        #logNetwork("프로필 조회 실패", error.localizedDescription)
      }
      return .none
      
    case .registerUser:
      return .run { [userEntity = state.userEntity] send in
        let registerUserResult = await Result {
          try await signUpUseCase.registerAccount(
            userName: userEntity.userName,
            email: userEntity.userEmail,
            password: userEntity.userUid
          )
        }
        
        switch registerUserResult {
        case .success(let registerUserData):
          if let registerUserData = registerUserData {
            await send(.async(.registerUserResponse(.success(registerUserData))))
            
            if !registerUserData.data.accessToken.isEmpty {
              await send(.navigation(.presentSignUpInviteView))
            }
          }
          
        case .failure(let error):
          await send(.async(.registerUserResponse(.failure(.encodingError("회원 가입 실패 \(error.localizedDescription)")))))
        }
      }
      
    case .registerUserResponse(let result):
      switch result {
      case .success(let registerDTO):
        state.$userEntity.withLock {
          $0.accessToken = registerDTO.data.accessToken
          $0.refreshToken = registerDTO.data.refreshToken
        }
        
      case .failure(let error):
        #logNetwork("회원가입 실패", error.localizedDescription)
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
    case .presentSignUpInviteView:
      return .none
      
    case .presentCoreMemberMain:
      return .none
      
    case .presentMemberMain:
      return .none
    }
  }
}
