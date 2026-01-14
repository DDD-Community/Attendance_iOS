//
//  SelectPartReducer.swift
//  Presentation
//
//  Created by Wonji Suh  on 11/3/24.
//

import Foundation

import Utill
import Entity

import ComposableArchitecture
import LogMacro

@Reducer
public struct SelectPartReducer {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    public init() {}

    var activeSelectPart: Bool = false
    var selectPart: SelectParts? = .all
    var selectJobs: IdentifiedArrayOf<SelectJob> = .init(uniqueElements: [])
    var errorMessage: String?
    var loading: Bool = false
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
    case selectPartButton(selectPart: SelectJob)
    case onAppear
  }
  
  // MARK: - AsyncAction 비동기 처리 액션
  
  public enum AsyncAction: Equatable {
    case getJobList
  }
  
  // MARK: - 앱내에서 사용하는 액션
  
  public enum InnerAction: Equatable {
    case jobListResponse(Result<[SelectJob], SignUpError>)
  }
  
  // MARK: - NavigationAction
  
  public enum NavigationAction: Equatable {
    case presentManaging
    case presentSelectTeam
    case presentNextStep
  }


  nonisolated enum CancelID: Hashable {
    case fetchJobList
  }

  @Dependency(\.onBoardingUseCase) var onBoardingUseCase

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

extension SelectPartReducer {
  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {

    case .selectPartButton(let selectJob):
      let selectedPart = selectJob.job

      if state.selectPart == selectedPart {
        // 동일한 파트 재선택 → 해제
        state.selectPart = nil
        state.$userSession.withLock { $0.selectPart = .all }
        state.activeSelectPart = false
        return .none
      }

      state.selectPart = selectedPart
        state.$userSession.withLock { $0.selectPart = selectedPart }
      state.activeSelectPart = true
//      #logDebug("selectPart", state.userEntity.role)
      return .none

      case .onAppear:
        return .send(.async(.getJobList))
    }
  }

  private func handleNavigationAction(
    state: inout State,
    action: NavigationAction
  ) -> Effect<Action> {
    switch action {
    case .presentManaging:
      return .none
    case .presentSelectTeam:
      return .none
    case .presentNextStep:
        return .run { [isAdmin = state.userSession.userRole] send in
        if isAdmin == .manager {
          await send(.navigation(.presentManaging))
        } else {
          await send(.navigation(.presentSelectTeam))
        }
      }
    }
  }

  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {
      case .getJobList:
        state.loading = true
        return .run { send in
          let jobListResult = await Result {
            try await onBoardingUseCase.fetchJobs()
          }
            .mapError(SignUpError.from)
          return await send(.inner(.jobListResponse(jobListResult)))
        }
        .cancellable(id: CancelID.fetchJobList, cancelInFlight: true)
    }

  }

  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {
      case .jobListResponse(let result):
        switch result {
          case .success(let data):
            state.loading = false
            state.selectJobs = .init(uniqueElements: data)

          case .failure(let error):
            state.errorMessage = error.errorDescription
            #logError("네트워크 통신 실패", error.errorDescription)
        }
        return .none

    }
  }
}
