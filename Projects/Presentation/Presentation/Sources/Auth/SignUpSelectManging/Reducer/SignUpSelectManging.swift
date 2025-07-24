//
//  SignUpSelectManaging.swift
//  Presentation
//
//  Created by Wonji Suh  on 11/3/24.
//

import Foundation

import Core
import Utill

import AsyncMoya
import ComposableArchitecture

@Reducer
public struct SignUpSelectManaging {
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
    case selectManagingButton(selectManaging: Managing)
  }
  
  // MARK: - AsyncAction 비동기 처리 액션
  
  public enum AsyncAction: Equatable {
    case editProfile
  }
  
  // MARK: - 앱내에서 사용하는 액션
  
  public enum InnerAction: Equatable {
    case editProfileResponse(Result<ProfileResponseModel, CustomError>)
  }
  
  // MARK: - NavigationAction
  
  public enum NavigationAction: Equatable {
    case presentCoreMember
    case presentSelectTeam
  }
  
  struct SignUpSelectManagingCancel: Hashable {}
  
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
    case .selectManagingButton(let selectManaging):
      if state.userEntity.managing == selectManaging {
        state.$userEntity.withLock { $0.managing = nil }
        state.activeButton = false
        return .none
      }
      state.$userEntity.withLock { $0.managing = selectManaging }
      if let selectManaging = Managing(rawValue: selectManaging.managingDesc) {
        state.$userEntity.withLock { $0.managing = selectManaging }
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
    case .presentCoreMember:
      return .none
      
    case .presentSelectTeam:
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
      ] send in
        let editProfileResult = await Result {
          try await profileUseCase.editProfileMangerNoTeam(
            name: userEntity.signUpName,
            inviteCode: userEntity.inviteCodeId ?? "",
            role: userEntity.role?.rawValue ?? "",
            responsibility: userEntity.managing?.rawValue ?? ""
          )
        }
        
        switch editProfileResult {
        case .success(let profileDTOData):
          if let profileDTOData = profileDTOData {
            await send(.inner(.editProfileResponse(.success(profileDTOData))))
            await send(.navigation(.presentCoreMember))
          }
          
        case .failure(let error):
          await send(.inner(.editProfileResponse(.failure(.encodingError("프로필업데이트 실패 : \(error.localizedDescription)")))))
        }
      }
      .debounce(id: SignUpSelectManagingCancel(), for: 0.3, scheduler: mainQueue)

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
