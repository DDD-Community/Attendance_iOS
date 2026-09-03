//
//  ScheduleManager.swift
//  Presentation
//
//  Created by DDD on 5/9/25.
//

import DDDCoreLogger
import Foundation

import DDDSharedUI

import ComposableArchitecture
import ScheduleDomainInterface
import AuthDomainInterface

@Reducer
public struct ScheduleReducer {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    
    public init() {}
    
    var scheduleModel: IdentifiedArrayOf<Schedule> = .init(uniqueElements: [])
    var loading: Bool = false
    var hasFetchedSchedule: Bool = false
    @Shared(.inMemory("UserSession")) var userSession: UserSession = .empty

  }
  
  public enum Action: ViewAction, BindableAction {
    case binding(BindingAction<State>)
    case view(View)
    case async(AsyncAction)
    case inner(InnerAction)
    case delegate(DelegateAction)
    
  }
  
  //MARK: - ViewAction
  @CasePathable
  public enum View {
    case onAppear
    case stratLoading
    case stopLoading
    
  }
  
  
  //MARK: - AsyncAction 비동기 처리 액션
  public enum AsyncAction: Equatable {
    case fetchSchedule
  }
  
  //MARK: - 앱내에서 사용하는 액션
  public enum InnerAction {
    case fetchScheduleResponse(Result<[Schedule], ScheduleError>)
  }
  
  //MARK: - DelegateAction
  public enum DelegateAction: Equatable {
    
    
  }
  
  nonisolated enum CancelID: Hashable {
    case fetchSchedule
  }

  @Dependency(\.scheduleUseCase) var scheduleUseCase
  @Dependency(\.mainQueue) var mainQueue
  @Dependency(\.continuousClock) var  clock
  
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
        
      case .delegate(let delegateAction):
        return handleDelegateAction(state: &state, action: delegateAction)
      }
    }
  }
}

extension ScheduleReducer {
  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
    case .onAppear:
      guard !state.hasFetchedSchedule else { return .none }
      state.hasFetchedSchedule = true
      return .send(.async(.fetchSchedule))

    case .stratLoading:
      state.loading = true
      return .none

    case .stopLoading:
      state.loading = false
      return .none
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
        let scheduleResult = await Result {
          try await scheduleUseCase.getSchedule()
        }
          .mapError(ScheduleError.from)
        return await send(.inner(.fetchScheduleResponse(scheduleResult)))

      }
      .cancellable(id: CancelID.fetchSchedule, cancelInFlight: true)
    }
  }

  private func handleDelegateAction(
    state: inout State,
    action: DelegateAction
  ) -> Effect<Action> {
    return .none
  }

  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {
    case .fetchScheduleResponse(let result):
      switch result {
      case .success(let schedules):
        state.scheduleModel = .init(uniqueElements: schedules)
          state.loading = false

      case .failure(let error):
        DDDLogger.error("스케줄 조회 실패: \(error.localizedDescription ?? "알 수 없는 오류")", category: .network)
        state.loading = false
      }
      return .none
    }
  }
}
