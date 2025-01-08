//
//  SignUpInviteCode.swift
//  Presentation
//
//  Created by Wonji Suh  on 11/2/24.
//

import Foundation
import ComposableArchitecture

import Utill
import Networkings
import AsyncMoya

@Reducer
public struct SignUpInviteCode {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    
    var firstInviteCode: String = ""
    var secondInviteCode: String = ""
    var thirdInviteCode: String = ""
    var lastInviteCode: String = ""
    var totalInviteCode: String {
      return firstInviteCode + secondInviteCode + thirdInviteCode + lastInviteCode
    }
    var enableButton: Bool {
      return !isNotAvaliableCode &&
      !firstInviteCode.isEmpty &&
      !secondInviteCode.isEmpty &&
      !thirdInviteCode.isEmpty &&
      !lastInviteCode.isEmpty
    }
    var isNotAvaliableCode: Bool = false
    var inviteCodeModel: InviteDTOModel? = nil
    
    @Shared var userSignUp: Member
    
    public init(
      userSignUp: Member
    ) {
      self._userSignUp = Shared(wrappedValue: userSignUp, .inMemory("Member"))
    }
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
  
  
  
  //MARK: - AsyncAction 비동기 처리 액션
  public enum AsyncAction: Equatable {
    case validataInviteCode(code: String)
    case validataInviteCodeResponse(Result<InviteDTOModel, CustomError>)
  }
  
  //MARK: - 앱내에서 사용하는 액션
  public enum InnerAction: Equatable {
    
  }
  
  //MARK: - NavigationAction
  public enum NavigationAction: Equatable {
    case presentSignUpName
  }
  
  struct SignUpInviteCodeCancel: Hashable {}
  
  @Dependency(SignUpUseCase.self) var signUpUseCase
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
    switch action {
      
    }
  }
  
  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {
    case .validataInviteCode(let code):
      return .run { send in
        let validataCodeResult = await Result {
          try await signUpUseCase.validateInviteCode(code: code)
        }
        
        switch validataCodeResult {
        case .success(let validataCodeData):
          if let validataCodeData = validataCodeData {
            await send(.async(.validataInviteCodeResponse(.success(validataCodeData))))
            
            await send(.navigation(.presentSignUpName))
          }
        case .failure(let error):
          await send(.async(.validataInviteCodeResponse(.failure(CustomError.firestoreError(error.localizedDescription)))))
        }
      }
      .debounce(id: SignUpInviteCodeCancel(), for: 0.3, scheduler: mainQueue)
      
    case .validataInviteCodeResponse(let result):
      switch result {
      case .success(let validateCodeData):
        state.inviteCodeModel = validateCodeData
        state.userSignUp.isAdmin = validateCodeData.isAdmin

        if validateCodeData.isAdmin == true {
            state.userSignUp.memberType = .coreMember
            
            // `memberDesc`를 `MemberType`의 `rawValue`로 변환하여 유효성을 확인한 후 할당
            if let part = MemberType(rawValue: state.userSignUp.memberType.rawValue) {
                state.userSignUp.memberType = part
            }
        } else {
            state.userSignUp.memberType = .member
          
          if let part = MemberType(rawValue: state.userSignUp.memberType.rawValue) {
              state.userSignUp.memberType = part
          } 
        }
      case .failure(let error):
        #logError("코드에러", error.localizedDescription)
        state.isNotAvaliableCode.toggle()
      }
      return .none
    }
  }
  
  private func handleNavigationAction(
    state: inout State,
    action: NavigationAction
  ) -> Effect<Action> {
    switch action {
    case .presentSignUpName:
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
}
