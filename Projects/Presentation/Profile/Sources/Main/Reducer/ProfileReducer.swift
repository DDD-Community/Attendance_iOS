//
//  ProfileReducer.swift
//  DDDAttendance
//
//  Created by 서원지 on 7/17/24.
//

import Foundation

import Shareds
import UseCase

import AsyncMoya
import ComposableArchitecture
import Entity
import DesignSystem

@Reducer
public struct ProfileReducer {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    var isLoading: Bool = false
    var managerProfileName: String = "의 프로필"
    var managerProfileRoleType: String = "직군"
    var memberSelectTeam: String = "소속 팀"
    var managerProfileManaging: String = "담당 업무"
    var managerProfileGeneration: String = "소속 기수"
    var logoutText: String = "로그아웃"

    var profileModel: ProfileEntity?
    var deleteUser: WithdrawEntity?
    var authExit: AuthExitEntity?
    var appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""

    @Shared(.inMemory("UserSession")) var userSession: UserSession = .empty
    @Presents var destination: Destination.State?
    @Shared(.appStorage("editGeneration")) var editGeneration: Bool = false

    // 기존 TCA AlertState 유지 (다른 곳에서 사용)
    @Presents public var alert: AlertState<AlertAction>?

    // TCA 스타일 CustomAlert (확인팝업용)
    @Presents public var customAlert: CustomAlertState<CustomAlertAction>?

    public init() {}
  }
  
  @Reducer(state: .equatable)
  public enum Destination {
    case createApp(CreateApp)
  }
  
  public enum Action: ViewAction, FeatureAction, BindableAction {
    case destination(PresentationAction<Destination.Action>)
    case binding(BindingAction<State>)
    case view(View)
    case async(AsyncAction)
    case inner(InnerAction)
    case scope(ScopeAction)
    case navigation(NavigationAction)

  }
  
  // MARK: - View action
  @CasePathable
  public enum View {
    case appearModal
    case closeModal
    case showWithdrawAlert
    case showLogoutAlert
  }
  
  // MARK: - 비동기 처리 액션
  @CasePathable
  public enum AsyncAction: Equatable {
    case fetchUser
    case deleteUser
    case logout
  }
  
  // MARK: - 앱내에서 사용하는 액션
  @CasePathable
  public enum InnerAction: Equatable {
    case fetchUserResponse(Result<ProfileEntity, ProfileError>)
    case deleteUserResponse(Result<WithdrawEntity, AuthError>)
    case logoutResponses(Result<AuthExitEntity, AuthError>)
  }
  
  // MARK: - 네비게이션 연결 액션
  @CasePathable
  public enum NavigationAction: Equatable {
    case presentLogOut
    case presentCreateByApp
    case presentPrivacyPolicy
    case presentEditGeneration
  }

  @CasePathable
  public enum ScopeAction {
    case alert(PresentationAction<AlertAction>)
    case customAlert(PresentationAction<CustomAlertAction>)
  }

  @CasePathable
  public enum AlertAction {
    case confirmTapped
  }

  nonisolated enum CancelID: Hashable {
    case fetchProfile
    case deleteUser
    case logoutUser
  }

  @Dependency(\.authUseCase) var authUseCase
  @Dependency(\.profileUseCase) var profileUseCase
  @Dependency(\.mainQueue) var mainQueue
  @Dependency(\.continuousClock) var clock
  
  public var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding(_):
        return .none
        
      case .destination(_):
        return .none
        
      // MARK: - ViewAction
        
      case .view(let viewAction):
        return handleViewAction(state: &state, action: viewAction)
        
      // MARK: - AsyncAction

      case .async(let asyncAction):
        return handleAsyncAction(state: &state, action: asyncAction)
        
      // MARK: - InnerAction
        
      case .inner(let innerAction):
        return handleInnerAction(state: &state, action: innerAction)
        
      // MARK: - NavigationAction
      case .navigation(let navigationAction):
        return handleNavigationAction(state: &state, action: navigationAction)

      case .scope(let scopeAction):
        switch scopeAction {
        case .alert:
          return .none

        case .customAlert(let customAlertAction):
          return handleCustomAlertAction(state: &state, action: customAlertAction)
        }
      }
    }
    .ifLet(\.$destination, action: \.destination)
    .ifLet(\.$alert, action: \.scope.alert)
    .ifLet(\.$customAlert, action: \.scope.customAlert) {
      EmptyReducer()
    }
  }
}

extension ProfileReducer {
  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
    case .appearModal:
      state.destination = .createApp(.init())
      return .none

    case .closeModal:
      state.destination = nil
      return .none

    case .showWithdrawAlert:
      state.customAlert = .withdrawAccount()
      return .none

    case .showLogoutAlert:
      state.customAlert = .logout()
      return .none

    }
  }

  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {

    case .fetchUser:
        state.isLoading = true
      return .run { send in
        let fetchUserResult = await Result {
          try await profileUseCase.getProfile()
        }
          .mapError(ProfileError.from)
        try await clock.sleep(for: .seconds(1))
        return await send(.inner(.fetchUserResponse(fetchUserResult)))
      }
      .cancellable(id: CancelID.fetchProfile, cancelInFlight: true)

      case .deleteUser:
        return .run {
          [
          userSession = state.userSession
        ] send in
          let deleteUserResult = await Result {
            try await authUseCase.withDraw(token: userSession.accessToken)
          }
            .mapError(AuthError.from)
          return await send(.inner(.deleteUserResponse(deleteUserResult)))

        }
        .cancellable(id: CancelID.deleteUser, cancelInFlight: true)

      case .logout:
        return .run { send in
          let logoutResult = await Result {
            try await authUseCase.logout()
          }
            .mapError(AuthError.from)
          return await send(.inner(.logoutResponses(logoutResult)))
        }
        .cancellable(id: CancelID.logoutUser, cancelInFlight: true)
    }
  }

  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {
    case .fetchUserResponse(let result):
      state.isLoading = false
      switch result {
      case .success(let profileDTOData):
        state.profileModel = profileDTOData

      case .failure(let error):
        #logError("유저 정보 가져오기", error.localizedDescription)
      }
      return .none


      case .deleteUserResponse(let result):
        switch result {
          case .success(let data):
            state.deleteUser = data
            if data.isSuccess {
              return .send(.navigation(.presentLogOut))
            }
            return .none

          case .failure(let error):
            state.alert = AlertState {
              TextState("탈퇴실패")
            } actions: {
              ButtonState(action: .confirmTapped) {
                TextState("확인")
              }
            } message: {
              TextState("회원 탈퇴 실패: \(String(describing: error.errorDescription ?? error.localizedDescription))")
            }
            return .none

        }

      case .logoutResponses(let result):
        switch result {
          case .success(let data):
            state.authExit = data
            return .send(.navigation(.presentLogOut))

          case .failure(let error):
            state.alert = AlertState {
              TextState("로그 아웃 실패")
            } actions: {
              ButtonState(action: .confirmTapped) {
                TextState("확인")
              }
            } message: {
              TextState("로그 아웃 실패: \(String(describing: AuthError.unknownError(error.errorDescription ?? "")))")
            }
            return .none
        }
    }
  }

  private func handleNavigationAction(
    state: inout State,
    action: NavigationAction
  ) -> Effect<Action> {
    switch action {
    case .presentLogOut:
      return .none

    case .presentCreateByApp:
      return .none

      case .presentPrivacyPolicy:
        return .none

      case .presentEditGeneration:
        state.$editGeneration.withLock { $0.toggle() }
        return .none
    }
  }

  private func handleCustomAlertAction(
    state: inout State,
    action: PresentationAction<CustomAlertAction>
  ) -> Effect<Action> {
    switch action {
    case .presented(let customAlertAction):
      switch customAlertAction {
      case .confirmTapped:
        // customAlert의 title로 구분하여 적절한 액션 실행
        guard let alertState = state.customAlert else { return .none }

        // 팝업 닫기
        state.customAlert = nil

        if alertState.title.contains("탈퇴") {
          return .send(.async(.deleteUser))
        } else if alertState.title.contains("로그아웃") {
          return .send(.async(.logout))
        }
        return .none

      case .cancelTapped:
        state.customAlert = nil
        return .none

        case .policyTapped:
          return .none
      }

    case .dismiss:
      return .none
    }
  }
}
