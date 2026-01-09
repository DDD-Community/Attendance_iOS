//
//  ScheduleManager.swift
//  Presentation
//
//  Created by Wonji Suh  on 5/9/25.
//

import Foundation

import Shareds

import ComposableArchitecture
import LogMacro

@Reducer
public struct ScheduleManager {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    
    public init() {}
    
    var scheduleModel: ScheduleModel?
    var loading: Bool = false
    
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
    case stratLoading
    case stopLoading
    
  }
  
  
  //MARK: - AsyncAction 비동기 처리 액션
  public enum AsyncAction: Equatable {
    case fetchSchedule
  }
  
  //MARK: - 앱내에서 사용하는 액션
  public enum InnerAction: Equatable {
    case fetchScheduleResponse(Result<ScheduleModel, CustomError>)
  }
  
  //MARK: - NavigationAction
  public enum NavigationAction: Equatable {
    
    
  }
  
  private struct ScheduleCancel: Hashable {}
  
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
        
      case .navigation(let navigationAction):
        return handleNavigationAction(state: &state, action: navigationAction)
      }
    }
  }
}

extension ScheduleManager {
  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
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
      return .run { send in
        let scheduleResult = await Result {
          try await scheduleUseCase.getSchedules()
        }

        await send(.view(.stratLoading))
        switch scheduleResult {
        case .success(let scheduleDTOData):
          if let scheduleDTOData = scheduleDTOData {
            await send(.inner(.fetchScheduleResponse(.success(scheduleDTOData))))
            try await clock.sleep(for: .seconds(1))
            await send(.view(.stopLoading))

          }

        case .failure(let error):
          await send(.inner(.fetchScheduleResponse(.failure(.encodingError("스케줄 조회 에러 \(error.localizedDescription)")))))
        }
      }
      .debounce(id: ScheduleCancel(), for: 0.3, scheduler: mainQueue)
    }
  }

  private func handleNavigationAction(
    state: inout State,
    action: NavigationAction
  ) -> Effect<Action> {

  }

  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {
    case .fetchScheduleResponse(let result):
      switch result {
      case .success(let scheduleDTOData):
        let sortedData = scheduleDTOData.data.sorted {
          $0.startTime < $1.startTime
        }
        state.scheduleModel = ScheduleModel(
          code: scheduleDTOData.code,
          message: scheduleDTOData.message,
          data: sortedData
        ) // 정렬된 데이터로 대체

      case .failure(let error):
        #logNetwork("스케줄 조회 실패", error.localizedDescription)
      }
      return .none
    }
  }
}

