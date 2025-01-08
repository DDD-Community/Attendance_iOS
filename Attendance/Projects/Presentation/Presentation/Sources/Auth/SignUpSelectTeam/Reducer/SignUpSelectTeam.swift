//
//  SignUpSelectTeam.swift
//  Presentation
//
//  Created by Wonji Suh  on 11/4/24.
//

import Foundation
import ComposableArchitecture

import Utill
import Networkings

@Reducer
public struct SignUpSelectTeam {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    public init() {}
    
    var selectTeam: SelectTeam? = .notTeam
    var activeButton: Bool = false
    @Shared(.inMemory("Member")) var userSignUpMember: Member = .init()
    @Shared(.appStorage("UserUID")) var userUid: String = ""
    @Shared(.appStorage("UserEmail")) var userEmail: String = ""
    var signUpMemberModel: MemberDTOSignUp? = nil
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
    case selectTeamButton(selectTeam: SelectTeam)
  }
  
  
  
  //MARK: - AsyncAction 비동기 처리 액션
  public enum AsyncAction: Equatable {
    case signUpMember
    case signUpMemberResponse(Result<MemberDTOSignUp, CustomError>)
  }
  
  //MARK: - 앱내에서 사용하는 액션
  public enum InnerAction: Equatable {
    
  }
  
  //MARK: - NavigationAction
  public enum NavigationAction: Equatable {
    case presentMember
    
  }
  
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
      case .selectTeamButton(let selectTeam):
        if state.selectTeam == selectTeam {
          state.selectTeam = nil
          state.userSignUpMember.memberTeam = nil
          state.activeButton = false
          return .none
        }
        
        state.selectTeam = selectTeam
        state.userSignUpMember.memberTeam = selectTeam
        if let selectTeam = SelectTeam(rawValue: selectTeam.selectTeamDesc) {
          state.userSignUpMember.memberTeam = selectTeam
        }
        
        state.activeButton = true
                return .none
      }
  }
  
  private func handleNavigationAction(
    state: inout State,
    action: NavigationAction
  ) -> Effect<Action> {
    switch action {
    case .presentMember:
      return .none
    }
  }
  
  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {
      
    case .signUpMember:
      return .run { [member = state.userSignUpMember] send in
        let member: Member = Member(
          uid: member.uid,
          memberid: member.uid,
          email: member.email,
          name: member.name,
          role: SelectPart(rawValue: member.role?.rawValue ?? "") ?? .all,
          memberType: MemberType(rawValue: member.memberType.rawValue) ?? .notYet,
          memberTeam: SelectTeam(rawValue: member.memberTeam?.rawValue ?? "") ?? .notTeam,
          isAdmin: member.isAdmin,
          generation: member.generation
        )
        let signUpCoreMemberResult = await Result {
          try await signUpUseCase.signUpMember(member: member)
        }
        
        switch signUpCoreMemberResult {
        case .success(let signUpMemberData):
          if let signUpMemberData = signUpMemberData {
            await send(.async(.signUpMemberResponse(.success(signUpMemberData))))
            try await clock.sleep(for: .seconds(1))
            await send(.navigation(.presentMember))
          }
        case .failure(let error):
          await send(.async(.signUpMemberResponse(.failure(CustomError.firestoreError(error.localizedDescription)))))
        }
      }
      
    case .signUpMemberResponse(let result):
      switch result {
      case .success(let signUpMemberData):
        state.signUpMemberModel = signUpMemberData
        state.userUid = signUpMemberData.uid
        state.userEmail = signUpMemberData.email
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
