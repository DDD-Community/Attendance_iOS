//
//  SignUpSelectManging.swift
//  Presentation
//
//  Created by Wonji Suh  on 11/3/24.
//

import Foundation

import Foundation
import ComposableArchitecture

import Utill
import Networkings
import AsyncMoya

@Reducer
public struct SignUpSelectManging {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    public init() {}
    var selectMangingPart : Managing? = .notManging
    var activeButton: Bool = false
    @Shared(.inMemory("Member")) var userSignUpMember: Member = .init()
    @Shared(.appStorage("UserUID")) var userUid: String = ""
    @Shared(.appStorage("UserEmail")) var userEmail: String = ""
    var signUpCoreMemberModel: CoreMemberDTOSignUp? = nil
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
    case selectMangingButton(selectManging: Managing)
  }
  
  
  
  //MARK: - AsyncAction 비동기 처리 액션
  public enum AsyncAction: Equatable {
    case signUpCoreMember
    case signUpCoreMemberResponse(Result<CoreMemberDTOSignUp, CustomError>)
  }
  
  //MARK: - 앱내에서 사용하는 액션
  public enum InnerAction: Equatable {
    
  }
  
  //MARK: - NavigationAction
  public enum NavigationAction: Equatable {
  case presntCoreMember
    
  }
  
  struct SignUpSelectMangingCancel: Hashable {}
  
  @Dependency(SignUpUseCase.self) var signUpUseCase
  @Dependency(\.continuousClock) var clock
  @Dependency(\.mainQueue) var mainQueue
  @Dependency(\.uuid) var uuid
  
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
      case .selectMangingButton(let selectManging):
        if state.selectMangingPart == selectManging {
          state.selectMangingPart = nil
          state.userSignUpMember.manging = nil
          state.activeButton = false
          return .none
        }
        state.selectMangingPart = selectManging
        if let selectManging = Managing(rawValue: selectManging.mangingDesc) {
          state.userSignUpMember.manging = selectManging
        }
        state.userSignUpMember.manging = selectManging
        state.activeButton = true
        return .none
      }
  }
  
  private func handleNavigationAction(
    state: inout State,
    action: NavigationAction
  ) -> Effect<Action> {
    switch action {
    case .presntCoreMember:
      return .none
    }
  }
  
  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {
    case .signUpCoreMember:
      return .run { [member = state.userSignUpMember] send in
        let member: Member = Member(
          uid: member.uid,
          memberid: member.uid,
          email: member.email,
          name: member.name,
          role: SelectPart(rawValue: member.role?.rawValue ?? "") ?? .all,
          memberType: MemberType(rawValue: member.memberType.rawValue) ?? .notYet,
          manging: Managing(rawValue: member.manging?.rawValue ?? "") ?? .notManging,
          isAdmin: member.isAdmin,
          generation: member.generation
        )
        let signUpCoreMemberResult = await Result {
          try await signUpUseCase.signUpCoreMember(member: member)
        }
        
        switch signUpCoreMemberResult {
        case .success(let signUpCoreMemberData):
          if let signUpCoreMemberData = signUpCoreMemberData {
            await send(.async(.signUpCoreMemberResponse(.success(signUpCoreMemberData))))
            try await clock.sleep(for: .seconds(1))
//            userUid = signUpCoreMemberData.uid
            if signUpCoreMemberData.isAdmin == true {
              await send(.navigation(.presntCoreMember))
            }
          }
        case .failure(let error):
          await send(.async(.signUpCoreMemberResponse(.failure(CustomError.firestoreError(error.localizedDescription)))))
        }
      }
      .debounce(id: SignUpSelectMangingCancel(), for: 0.3, scheduler: mainQueue)
      
    case .signUpCoreMemberResponse(let result):
      switch result {
      case .success(let signUpCoreMemberData):
        state.signUpCoreMemberModel = signUpCoreMemberData
        state.userUid = signUpCoreMemberData.uid
        state.userEmail = signUpCoreMemberData.email
      case .failure(let error):
        #logError("회원가입 실패", error.localizedDescription)
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
}
