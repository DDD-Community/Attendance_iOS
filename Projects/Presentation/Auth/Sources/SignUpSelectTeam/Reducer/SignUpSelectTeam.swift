//
//  SignUpSelectTeam.swift
//  Presentation
//
//  Created by Wonji Suh  on 11/4/24.
//

import Foundation

import Utill
import UseCase
import Entity

import ComposableArchitecture
import LogMacro

@Reducer
public struct SignUpSelectTeam {
  public init() {}

  @ObservableState
  public struct State: Equatable {
    public init() {}

    var activeButton: Bool = false
    var selectTeam: SelectTeams? = .unknown
    var loading: Bool = false
    var errorMessage: String?
    var teams: [SelectTeamEntity]? = []
    var signUpUser: SignUpUser?


    @Shared(.inMemory("UserSession")) var userSession: UserSession = .empty
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
    case selectTeamButton(selectTeam: SelectTeamEntity)
    case onAppear
  }
  
  // MARK: - AsyncAction 비동기 처리 액션
  
  public enum AsyncAction: Equatable {
    case getTeams
    case signUpUser
  }
  
  // MARK: - 앱내에서 사용하는 액션
  
  public enum InnerAction: Equatable {
    case teamListResponse(Result<[SelectTeamEntity], SignUpError>)
    case signUpUserResponse(Result<SignUpUser, SignUpError>)
  }
  
  // MARK: - NavigationAction
  
  public enum NavigationAction: Equatable {
    case presentMember
    case presentManager
  }
  
  nonisolated enum CancelID: Hashable {
    case selectTeam
    case signUpUser
  }

  
  @Dependency(\.signUpUseCase) var signUpUseCase
  @Dependency(\.onBoardingUseCase) var onBoardingUseCase
  @Dependency(\.continuousClock) var clock
  
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
    case .selectTeamButton(let selectTeams):
        let selectTeam = selectTeams.teams
        let teamId = selectTeams.teamId

        if state.selectTeam == selectTeam {
          // 동일한 파트 재선택 → 해제
          state.selectTeam = nil
          state.$userSession.withLock {
            $0.selectTeam = .unknown
            $0.selectTeamId = nil
          }
          state.activeButton = false
          return .none
        }

        state.selectTeam = selectTeam
        state.$userSession.withLock {
          $0.selectTeam = selectTeam
          $0.selectTeamId = teamId
        }

        state.activeButton = true
  //      #logDebug("selectPart", state.userEntity.role)
        return .none

        case .onAppear:
          return .send(.async(.getTeams))

    }
  }
  
  private func handleNavigationAction(
    state: inout State,
    action: NavigationAction
  ) -> Effect<Action> {
    switch action {
    case .presentMember:
      return .none
      
    case .presentManager:
      return .none
    }
  }
  
  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {
      case .getTeams:
        state.loading = true
        return .run {
          [userSession =  state.userSession]
          send in
          let teamResult = await Result {
            try await onBoardingUseCase.fetchTeams(generationId: userSession.generationId)
          }
            .mapError(SignUpError.from)
          return await send(.inner(.teamListResponse(teamResult)))

        }
        .cancellable(id: CancelID.selectTeam, cancelInFlight: true)

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

      
    }
  }
  
  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {
      case .teamListResponse(let result):
        switch result {
          case .success(let data):
            state.teams = data
            state.loading = false
          case .failure(let error):
            #logError("네트워크 에러 ", error.errorDescription ?? "알 수 없음")
        }
        return .none

      case .signUpUserResponse(let result):
        switch result {
          case .success(let data):
            state.signUpUser = data

            if state.userSession.userRole == .manager {
              return .send(.navigation(.presentManager))
            } else {
              return .send(.navigation(.presentMember))
            }

          case .failure(let error):
            state.errorMessage = error.errorDescription
            return .none
        }

    }
  }
}
