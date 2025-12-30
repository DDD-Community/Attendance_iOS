//
//  SignUpPart.swift
//  Presentation
//
//  Created by Wonji Suh  on 11/3/24.
//

import Foundation

import Core
import Utill
import Entity

import ComposableArchitecture

@Reducer
public struct SignUpPart {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    public init() {}
    
    var activeSelectPart: Bool = false
    var selectPart: SelectParts? = .all
    var selectJobs: [SelectJob]? = []
    var errorMessage: String?
    var loading: Bool = false
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

    case .selectPartButton(let selectJob):
      let selectedPart = selectJob.job

      if state.selectPart == selectedPart {
        // 동일한 파트 재선택 → 해제
        state.selectPart = nil
        // TODO: - 차후에 수정
//        state.$userEntity.withLock { $0.role = nil }
        state.activeSelectPart = false
        return .none
      }

      state.selectPart = selectedPart
        // TODO: - 차후에 수정
//      state.$userEntity.withLock { $0.role = selectedPart }
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
      return .run { [isAdmin = state.userEntity.userRole] send in
        if isAdmin == .moderator {
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
            .mapError { error -> SignUpError in
              if let authError = error as? SignUpError {
                return authError
              } else {
                return .unknownError(error.localizedDescription)
              }
            }
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
            state.selectJobs = data

          case .failure(let error):
            state.errorMessage = error.errorDescription
            #logError("네트워크 통신 실패", error.errorDescription)
        }
        return .none

    }
  }
}
