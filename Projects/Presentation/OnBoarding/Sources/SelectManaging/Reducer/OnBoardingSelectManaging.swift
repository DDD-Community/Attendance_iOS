//
//  OnBoardingSelectManaging.swift
//  Presentation
//
//  Created by Wonji Suh  on 11/3/24.
//

import Foundation

import UseCase
import Entity
import Utill

import AsyncMoya
import ComposableArchitecture

@Reducer
public struct SelectManagingReducer {
  public init() {}

  @ObservableState
  public struct State: Equatable {
    public init() {}

    var loading: Bool = false
    var activeButton: Bool = false
    var errorMessage: String?
    var selectMangers: IdentifiedArrayOf<SelectManaging> = .init(uniqueElements: [])
    var signUpUser: SignUpUser?
    var editProfile: ProfileEntity?

    @Shared(.inMemory("UserSession")) var userSession: UserSession = .empty
    @Shared(.appStorage("editGeneration")) var editGeneration: Bool = false
    @Shared(.appStorage("staffRole")) var staffRole: Staff?
    @Presents var alert: AlertState<AlertAction>?


  }

  public enum Action: ViewAction, BindableAction, FeatureAction {
    case binding(BindingAction<State>)
    case view(View)
    case async(AsyncAction)
    case inner(InnerAction)
    case navigation(NavigationAction)
    case scope(ScopeAction)
  }

  // MARK: - ViewAction

  @CasePathable
  public enum View {
    case onAppear
    case selectManagingButton(selectManaging: SelectManaging)
    case signUp
  }

  @CasePathable
  public enum ScopeAction {
      case alert(PresentationAction<AlertAction>)
  }

  @CasePathable
  public enum AlertAction {
    case confirmTapped
  }


  // MARK: - AsyncAction 비동기 처리 액션

  public enum AsyncAction: Equatable {
    case fetchMangerList
    case signUpUser
    case editProfile
  }

  // MARK: - 앱내에서 사용하는 액션

  public enum InnerAction: Equatable {
    case mangerListResponse(Result<[SelectManaging], SignUpError>)
    case signUpUserResponse(Result<SignUpUser, SignUpError>)
    case editProfileResponse(Result<ProfileEntity, ProfileError>)
  }

  // MARK: - NavigationAction

  public enum NavigationAction: Equatable {
    case presentManager
    case presentSelectTeam
    case presentProfile
  }

  nonisolated enum CancelID: Hashable, CaseIterable {
    case fetchMangerList
    case signUpUser
    case editProfile
  }

  @Dependency(\.onBoardingUseCase) var onBoardingUseCase
  @Dependency(\.signUpUseCase) var signUpUseCase
  @Dependency(\.profileUseCase) var profileUseCase
  @Dependency(\.continuousClock) var clock
  @Dependency(\.mainQueue) var mainQueue

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

        case .scope:
          return .none
      }
    }
    .ifLet(\.$alert, action: \.scope.alert)
  }
}

extension SelectManagingReducer {
  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
      case .onAppear:
        // 이미 데이터가 있다면 다시 fetch하지 않음
        if !state.selectMangers.isEmpty {
          return .none
        }
        return .send(.async(.fetchMangerList))

      case .selectManagingButton(let selectManaging):
        let selectedManaging = selectManaging.managing
        var updatedManaging: [StaffManaging] = []

        state.$userSession.withLock {
          var current = $0.managing
          if let index = current.firstIndex(of: selectedManaging) {
            current.remove(at: index)
          } else {
            current.append(selectedManaging)
          }
          $0.managing = current
          updatedManaging = current
        }

        state.activeButton = !updatedManaging.isEmpty
        return .none


      case .signUp:
        return .run { [
          editGeneration = state.editGeneration
        ] send in
          if editGeneration == true {
            await send(.async(.editProfile))
          } else {
            await send(.async(.signUpUser))
          }
        }
    }
  }

  private func handleNavigationAction(
    state: inout State,
    action: NavigationAction
  ) -> Effect<Action> {
    // 모든 navigation에서 진행 중인 effect를 cancel
//    let cancelEffects = Effect<Action>.merge(
//      CancelID.allCases.map { .cancel(id: $0) }
//    )

    switch action {
      case .presentManager:
        return .none

      case .presentSelectTeam:
        return .none

      case .presentProfile:
        return .none
    }
  }

  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {
      case .fetchMangerList:
        state.loading = true
        return .run { send in
          let mangerResult = await Result {
            try await onBoardingUseCase.fetchManaging()
          }
            .mapError(SignUpError.from)
          return await send(.inner(.mangerListResponse(mangerResult)))
        }
        .cancellable(id: CancelID.fetchMangerList, cancelInFlight: true)

      case .signUpUser:
        return .run { [
          userSession = state.userSession
        ] send in
          let signUpUserResult = await Result {
            return try await signUpUseCase.registerUser(userSession: userSession)
          }
          .mapError(SignUpError.from)
          return await send(.inner(.signUpUserResponse(signUpUserResult)))
        }
        .cancellable(id: CancelID.signUpUser, cancelInFlight: true)


      case .editProfile:
        return .run { [
          userSession = state.userSession
        ] send in
          let editProfileResult = await Result {
            return try await profileUseCase.editUser(userSession: userSession)
          }
          .mapError(ProfileError.from)
          return await send(.inner(.editProfileResponse(editProfileResult)))
        }
        .cancellable(id: CancelID.editProfile, cancelInFlight: true)

    }
  }

  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {
      case .mangerListResponse(let result):
        switch result {
          case .success(let data):
            state.loading = false
            state.selectMangers = .init(uniqueElements: data)

          case .failure(let error):
            state.errorMessage =  error.errorDescription

        }
        return .none

      case .signUpUserResponse(let result):
        switch result {
          case .success(let data):
            state.signUpUser = data
            state.$staffRole.withLock { $0 = state.userSession.userRole }

            return .send(.navigation(.presentManager))

          case .failure(let error):
            state.errorMessage = error.errorDescription
            state.alert = AlertState {
              TextState("회원가입 실패")
            } actions: {
              ButtonState(action: .confirmTapped) {
                TextState("확인")
              }
            } message: {
              TextState(error.errorDescription ?? "알 수 없는 오류가 발생했습니다.")
            }
            return .none
        }

      case .editProfileResponse(let result):
        switch result {
          case .success(let data):
            state.editProfile = data
            state.$editGeneration.withLock { $0 = false }
            state.$staffRole.withLock { $0 = state.userSession.userRole }

            if state.userSession.userRole == .manager {
              return .send(.navigation(.presentManager))
            } else {
              return .send(.navigation(.presentMember))
            }

          case .failure(let error):
            state.errorMessage = error.errorDescription
            state.$editGeneration.withLock { $0 = false }
            state.alert = AlertState {
              TextState("프로필 수정 실패")
            } actions: {
              ButtonState(action: .confirmTapped) {
                TextState("확인")
              }
            } message: {
              TextState(error.errorDescription ?? "알 수 없는 오류가 발생했습니다.")
            }
            return .none
        }
    }

  }
}
