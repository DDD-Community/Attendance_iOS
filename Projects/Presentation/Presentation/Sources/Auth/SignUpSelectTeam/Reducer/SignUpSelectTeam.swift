//
//  SignUpSelectTeam.swift
//  Presentation
//
//  Created by Wonji Suh  on 11/4/24.
//

import Foundation

import Utill
import Networkings

import ComposableArchitecture

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
    
    var editProfileDTO: ProfiledDTO?
    @Shared(.inMemory("UserEntity")) var userEntity: UserEntity = .shared
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
    case selectTeamButton(selectTeam: SelectTeam)
  }
  
  // MARK: - AsyncAction 비동기 처리 액션
  
  public enum AsyncAction: Equatable {
    case signUpMember
    case signUpMemberResponse(Result<MemberDTOSignUp, CustomError>)
    case editProfile
    case editProfileResponse(Result<ProfiledDTO, CustomError>)
  }
  
  // MARK: - 앱내에서 사용하는 액션
  
  public enum InnerAction: Equatable {
    
  }
  
  // MARK: - NavigationAction
  
  public enum NavigationAction: Equatable {
    case presentMember
    case presentCoreMember
  }
  
  
  private struct SignUpSelectTeamCancel: Hashable {}
  
  @Dependency(SignUpUseCase.self) var signUpUseCase
  @Dependency(\.continuousClock) var clock
  @Dependency(ProfileUseCase.self) var profileUseCase
  @Dependency(\.mainQueue) var mainQueue
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
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
      if state.userEntity.memberTeam == selectTeam {
        state.$userEntity.withLock { $0.memberTeam = nil}
        state.activeButton = false
        return .none
      }
      
      state.$userEntity.withLock { $0.memberTeam = selectTeam }
      
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
      
    case .presentCoreMember:
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
        state.$userUid.withLock { $0  = signUpMemberData.uid}
        state.$userEmail.withLock { $0 = signUpMemberData.email } 
      case .failure(let error):
        #logError("회원가입 실패", error.localizedDescription)
      }
      return .none
      
    case .editProfile:
      return .run { [
        userEntity = state.userEntity,
      ] send in
        let isStaff = userEntity.userRole
        let memberTeam = userEntity.memberTeam?.managingTeamDesc ?? ""
        let isAdminRole =   "\(userEntity.managing?.managingDesc ?? "") / \(memberTeam)"
        let editProfileResult = await Result {
          try await profileUseCase.editProfile(
            name: userEntity.signUpName,
            inviteCode: userEntity.inviteCodeId ?? "",
            role: isStaff == .moderator ? isAdminRole : memberTeam,
            team: userEntity.role?.desc ??  ""
          )
        }
        
        switch editProfileResult {
        case .success(let profileDTOData):
          if let profileDTOData = profileDTOData {
            await send(.async(.editProfileResponse(.success(profileDTOData))))
            
            if profileDTOData.code == 200 {
              if profileDTOData.data?.isStaff == true {
                await send(.navigation(.presentCoreMember))
              } else {
                await send(.navigation(.presentMember))
              }
            }
          }
          
        case .failure(let error):
          await send(.async(.editProfileResponse(.failure(.encodingError("프로필업데이트 실패 : \(error.localizedDescription)")))))
        }
      }
      .debounce(id: SignUpSelectTeamCancel(), for: 0.3, scheduler: mainQueue)
      
    case .editProfileResponse(let result):
      switch result {
      case .success(let profileDT0):
        state.editProfileDTO = profileDT0
        
      case .failure(let error):
        #logNetwork("회원가입 프로핍 변경  에러", error.localizedDescription)
      }
      return .none
    }
  }
  
  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    
  }
}
