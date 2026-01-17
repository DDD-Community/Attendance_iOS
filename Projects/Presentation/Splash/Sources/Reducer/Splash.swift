//
//  Splash.swift
//  Presentation
//
//  Created by Wonji Suh  on 10/29/24.
//

import Foundation

import Shareds
import Utill
import UseCase
import Entity

import ComposableArchitecture
import LogMacro

@Reducer
public struct Splash {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {

    @Shared(.inMemory("UserEntity")) var userEntity: UserEntity = .shared
    @Shared(.appStorage("staffRole")) var staffRole: Staff?
    var profileModel: ProfileEntity?

    public init() {

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
    case onAppear

  }
  
  // MARK: - AsyncAction 비동기 처리 액션
  
  public enum AsyncAction: Equatable {
    case fetchUser
  }
  
  // MARK: - 앱내에서 사용하는 액션
  
  public enum InnerAction: Equatable {
    case fetchUserResponse(Result<ProfileEntity, ProfileError>)
  }
  
  // MARK: - NavigationAction
  
  public enum NavigationAction: Equatable {
    case presentLogin
    case presentStaff
    case presentMember
  }
  
  nonisolated enum CancelID: Hashable {
    case fetchProfile
  }



  @Dependency(\.continuousClock) var clock
  @Dependency(\.profileUseCase) var profileUseCase
  @Dependency(\.mainQueue) var mainQueue
  @Dependency(\.keychainManager) var keychainManager
  
  public var body: some Reducer<State, Action> {
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
}

extension Splash {
  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
      case .onAppear:
        return .run { [
          staffRole = state.staffRole
        ] send in
          if staffRole == .manager {
            #logDebug("👔 [Splash] Redirecting to staff")
            return await send(.navigation(.presentStaff))
          } else if staffRole == .member {
            #logDebug("👤 [Splash] Redirecting to member")
            return await send(.navigation(.presentMember))
          } else {
            #logDebug("❓ [Splash] No staff role - redirecting to login")
            return await send(.navigation(.presentLogin))
          }
        }
    }

  }

  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {
      case .fetchUser:
        return .run { send in
          let fetchUserResult = await Result {
            try await profileUseCase.getProfile()
          }
            .mapError(ProfileError.from)
          try await clock.sleep(for: .seconds(1))
          return await send(.inner(.fetchUserResponse(fetchUserResult)))
        }
        .cancellable(id: CancelID.fetchProfile, cancelInFlight: true)
    }
  }

  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {
      case .fetchUserResponse(let result):
        switch result {
        case .success(let profileDTOData):
          #logDebug("✅ [Splash] User profile fetched successfully")
          state.profileModel = profileDTOData
          return .none // 성공한 경우 navigation은 이미 처리됨

        case .failure(let error):
          #logError("❌ [Splash] Failed to fetch user profile", error.localizedDescription)

          // 토큰 만료나 인증 에러의 경우 로그인으로 이동
          // 다른 네트워크 에러의 경우에도 안전하게 로그인으로 이동
          keychainManager.clear()
          return .send(.navigation(.presentLogin))
        }
    }
  }

  private func handleNavigationAction(
    state: inout State,
    action: NavigationAction
  ) -> Effect<Action> {
    switch action {
    case .presentLogin:
      return .none

    case .presentStaff:
        return .send(.async(.fetchUser))

    case .presentMember:
        return .send(.async(.fetchUser))
    }
  }
}
