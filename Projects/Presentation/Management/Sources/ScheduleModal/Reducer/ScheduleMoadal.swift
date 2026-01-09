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
import Entity
import LogMacro

@Reducer
public struct ScheduleModal {
  public init() {}

  @ObservableState
  public struct State: Equatable {
    var scheduleModel: [ScheduleEntity]?
    var loading: Bool = false
    var enableButton: Bool = false
    var selectedSchedule: ScheduleEntity? = nil

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
    case selectSchedule(item: ScheduleEntity)
    case confirmSelection
  }

  //MARK: - AsyncAction 비동기 처리 액션
  public enum AsyncAction: Equatable {
    case fetchSchedule

  }

  //MARK: - 앱내에서 사용하는 액션
  public enum InnerAction: Equatable {
    case scheduleResponse(Result<[ScheduleEntity], ScheduleError>)
  }

  //MARK: - NavigationAction
  public enum NavigationAction: Equatable {
    case selectScheduleCompleted(selectedSchedule: ScheduleEntity)
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
    case .selectSchedule(let item):
      if state.selectedSchedule?.id == item.id {
        state.selectedSchedule = nil
      } else {
        state.selectedSchedule = item
      }
      state.enableButton = state.selectedSchedule != nil
      return .none

    case .confirmSelection:
      guard let selectedSchedule = state.selectedSchedule else {
        return .none
      }
      return .send(.navigation(.selectScheduleCompleted(selectedSchedule: selectedSchedule)))
    }
  }

  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {
      case .fetchSchedule:
        state.loading = true
        return .run { send in
          let result = await Result {
            try await scheduleUseCase.getSchedule()
          }
            .mapError(ScheduleError.from)
          return await send(.inner(.scheduleResponse(result)))
        }
    }
  }

  private func handleNavigationAction(
    state: inout State,
    action: NavigationAction
  ) -> Effect<Action> {
    switch action {
      case .selectScheduleCompleted(_):
      return .none
    }
  }

  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {
      case .scheduleResponse(let result):
        #logDebug("스케줄 응답 처리", "로딩 완료")
        state.loading = false  
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

