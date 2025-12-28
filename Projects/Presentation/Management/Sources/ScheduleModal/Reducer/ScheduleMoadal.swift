//
//  ScheduleModal.swift
//  Management
//
//  Created by Wonji Suh  on 12/27/25.
//

import Foundation

import Shareds
import UseCase

import ComposableArchitecture
import LogMacro

@Reducer
public struct ScheduleModal {
  public init() {}

  @ObservableState
  public struct State: Equatable {
    var scheduleModel: ScheduleModel?
    var loading: Bool = false
    var enableButton: Bool = false

    public init() {}
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

  }

  //MARK: - AsyncAction 비동기 처리 액션
  public enum AsyncAction: Equatable {
    case fetchSchedule

  }

  //MARK: - 앱내에서 사용하는 액션
  public enum InnerAction: Equatable {
    case scheduleResponse(Result<ScheduleModel?, CustomError>)
  }

  //MARK: - NavigationAction
  public enum NavigationAction: Equatable {

  }

  nonisolated enum ScheduleMoadalCancel: Hashable {
    case fetchSchedule
  }

  @Dependency(\.scheduleUseCase) var scheduleUseCase


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

extension ScheduleModal {
  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {

    }
  }

  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {
      case .fetchSchedule:
        state.loading = true  // 로딩 시작
        return .run { send in
          let result = await Result {
            try await scheduleUseCase.getSchedules()
          }
            .mapError { error -> CustomError in
                if let scehduleError = error as? CustomError {
                    return scehduleError
                } else {
                    return .unknownError(error.localizedDescription)
                }
            }
          return await send(.inner(.scheduleResponse(result)))
        }
    }
  }

  private func handleNavigationAction(
    state: inout State,
    action: NavigationAction
  ) -> Effect<Action> {
    switch action {

    }
  }

  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {
      case .scheduleResponse(let result):
        state.loading = false  // 로딩 완료
        switch result {
          case .success(let data):
            state.scheduleModel = data
          case .failure(let error):
            #logNetwork("네트워크 에러", error.localizedDescription)
        }
        return .none
    }
  }
}

