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

    var activeButton: Bool = false
    var editProfileDTO: ProfileResponseModel?
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
    case editProfile
    case editProfileManger
    case editProfileMember
  }

  // MARK: - 앱내에서 사용하는 액션

  public enum InnerAction: Equatable {
    case editProfileResponse(Result<ProfileDTOModel, CustomError>)
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
    case .editProfile:
      return .run { [
        userEntity = state.userEntity,
      ]  send in
        if userEntity.userRole == .moderator {
          await send(.async(.editProfileManger))
        } else {
          await send(.async(.editProfileMember))
        }
      }
      
    case .editProfileManger:
      return .run { [
        userEntity = state.userEntity,
      ] send in
        let memberTeam = userEntity.memberTeam?.rawValue ?? ""
        let isAdminRole = "\(userEntity.managing?.rawValue ?? "")"
        let editProfileResult = await Result {
          try await profileUseCase.editProfileManger(
            name: userEntity.signUpName,
            inviteCode: userEntity.inviteCodeId ?? "",
            role: userEntity.role?.rawValue ?? "",
            crew: memberTeam,
            responsibility: isAdminRole
          )
        }

        switch editProfileResult {
        case .success(let profileDTOData):
          if let profileDTOData = profileDTOData {
            await send(.async(.editProfileResponse(.success(profileDTOData))))
            await send(.navigation(.presentCoreMember))
          }
          
        case .failure(let error):
          await send(.inner(.editProfileResponse(.failure(.encodingError("프로필업데이트 실패 : \(error.localizedDescription)")))))
        }
      }
      .debounce(id: SignUpSelectTeamCancel(), for: 0.3, scheduler: mainQueue)
      
    case .editProfileMember:
      return .run { [
        userEntity = state.userEntity,
      ] send in
        let memberTeam = userEntity.memberTeam?.rawValue ?? ""
        let editProfileResult = await Result {
          try await profileUseCase.editProfileMember(
            name: userEntity.signUpName,
            inviteCode: userEntity.inviteCodeId ?? "",
            role: userEntity.role?.rawValue ?? "",
            crew: memberTeam
          )
        }
        
        switch editProfileResult {
        case .success(let profileDTOData):
          if let profileDTOData = profileDTOData {
            await send(.inner(.editProfileResponse(.success(profileDTOData))))
            
            if profileDTOData.code == 200 {
              await send(.navigation(.presentMember))
            }
          }

        case .failure(let error):
          await send(.inner(.editProfileResponse(.failure(.encodingError("프로필업데이트 실패 : \(error.localizedDescription)")))))
        }
      }
      .debounce(id: SignUpSelectTeamCancel(), for: 0.3, scheduler: mainQueue)
      
    }
  }
  
  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {
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
}
