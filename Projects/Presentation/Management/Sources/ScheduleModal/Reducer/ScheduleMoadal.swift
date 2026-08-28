//
//  ScheduleMoadal.swift
//  Management
//
//  Created by Wonji Suh  on 12/27/25.
//

import Foundation

import DDDSharedUI
import UseCase

import ComposableArchitecture
import Entity
import LogMacro

@Reducer
public struct ScheduleModal {
  public init() {}

  @ObservableState
  public struct State: Equatable {
    var scheduleModel: IdentifiedArrayOf<Schedule> = .init(uniqueElements: [])
    var loading: Bool = false
    var enableButton: Bool = false
    var selectedSchedule: Schedule?

    public init() {}
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
    case selectSchedule(item: Schedule)
    case confirmSelection
  }

  // MARK: - AsyncAction 비동기 처리 액션

  public enum AsyncAction: Equatable {
    case fetchSchedule
  }

  // MARK: - 앱내에서 사용하는 액션

  public enum InnerAction: Equatable {
    case scheduleResponse(Result<[Schedule], ScheduleError>)
  }

  // MARK: - NavigationAction

  public enum NavigationAction: Equatable {
    case selectScheduleCompleted(selectedSchedule: Schedule)
  }

  nonisolated enum ScheduleMoadalCancel: Hashable {
    case fetchSchedule
  }

  @Dependency(\.scheduleUseCase) var scheduleUseCase
  @Dependency(\.continuousClock) var clock

  public var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case let .view(viewAction):
        return handleViewAction(state: &state, action: viewAction)

      case let .async(asyncAction):
        return handleAsyncAction(state: &state, action: asyncAction)

      case let .inner(innerAction):
        return handleInnerAction(state: &state, action: innerAction)

      case let .navigation(navigationAction):
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
    case let .selectSchedule(item):
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
      // 캐시 있으면 로딩 표시 X (SWR로 백그라운드 갱신)
      state.loading = state.scheduleModel.isEmpty
      return .run { send in
        if let cached = await scheduleUseCase.getCachedSchedule(), !cached.isEmpty {
          await send(.inner(.scheduleResponse(.success(cached))))
          _ = try? await scheduleUseCase.getSchedule()
          return
        }
        let result = await Result {
          try await scheduleUseCase.getSchedule()
        }
        .mapError(ScheduleError.from)
        try await clock.sleep(for: .seconds(0.6))
        await send(.inner(.scheduleResponse(result)))
      }
    }
  }

  private func handleNavigationAction(
    state _: inout State,
    action: NavigationAction
  ) -> Effect<Action> {
    switch action {
    case .selectScheduleCompleted:
      return .none
    }
  }

  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {
    case let .scheduleResponse(result):
      #logDebug("스케줄 응답 처리", "로딩 완료")
      state.loading = false
      switch result {
      case let .success(data):
        state.scheduleModel = .init(uniqueElements: data)
      case let .failure(error):
        #logNetwork("네트워크 에러", error.localizedDescription)
      }
      return .none
    }
  }
}
