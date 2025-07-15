//
//  AttendanceCheck.swift
//  Presentation
//
//  Created by Wonji Suh  on 1/16/25.
//

import Foundation

import Shareds
import Networkings

import ComposableArchitecture
import FirebaseAuth

@Reducer
public struct AttendanceCheck {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    
    var selectAttandanceDate: Date = .now
    var selectAttandanceDateMonth: Date = .now
    var selectPart: SelectTeam? = .web1
    
    var dividerWidths: [SelectTeam: CGFloat] = [:]
    
    var isLoading: Bool = false
    var attendanceCount: Int = .zero
    var lateCount: Int = .zero
    var absentCount: Int = .zero
    
    @Presents var destination: Destination.State?
    @Shared(.inMemory("Member")) var userSignUpMember: Member = .init()
    
    var attendanceCountDTOModel: AttendanceCountResponseModel?
    var attendCheckModel: AttendanceListModel?
    var sceheduleAttandanceModel: ScheduleModel?

    
    public init() {
      
    }
  }
  
  public enum Action: ViewAction, BindableAction, FeatureAction {
    case destination(PresentationAction<Destination.Action>)
    case binding(BindingAction<State>)
    case view(View)
    case async(AsyncAction)
    case inner(InnerAction)
    case navigation(NavigationAction)
    
  }
  
  @Reducer(state: .equatable)
  public enum Destination {
    case selectDate(CustomDate)
  }
  
  // MARK: - ViewAction
  @CasePathable
  public enum View {
    case selectPartButton(selectPart: SelectTeam)
    case swipeNext
    case swipePrevious
    case appearSelectDate
    case closeModal
  }
  
  // MARK: - AsyncAction 비동기 처리 액션
  public enum AsyncAction: Equatable {
    case appearData
    case fetchAttendanceCount
    case filterAttendanceCount(startDate: String)
    case fetchScheduleAttedanceCheck
  }
  
  // MARK: - 앱내에서 사용하는 액션
  public enum InnerAction: Equatable {
    case attendanceCountResponse(Result<AttendanceCountResponseModel, CustomError>)
    case scheduleAttendanceCheckResponse(Result<ScheduleModel, CustomError>)
    case fillterAttendance(team: SelectTeam)
  }
  
  // MARK: - NavigationAction
  public enum NavigationAction: Equatable {

  }
  
  private struct AttendanceCheckCancel: Hashable {}
  
  @Dependency(AttendanceUseCase.self) var attendanceUseCase
  @Dependency(ScheduleUseCase.self) var scheduleUseCase
  @Dependency(\.continuousClock) var clock
  @Dependency(\.mainQueue) var mainQueue
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding(_):
        return .none
        
      case .destination(_):
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
    .ifLet(\.$destination, action: \.destination)
    .onChange(of: \.sceheduleAttandanceModel) { oldValue, newValue in
      Reduce { state, action in
        state.sceheduleAttandanceModel = newValue
        return .none
      }
    }
  }
  
  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
    case .selectPartButton(let selectPart):
      state.selectPart = selectPart
      return .none
      
    case .swipeNext:
      guard let selectPart = state.selectPart else { return .none }

      if selectPart == .ios2 {
        state.selectPart = .web1
      } else if let currentIndex = SelectTeam.allCases.firstIndex(of: selectPart),
                currentIndex < SelectTeam.allCases.count - 1 {
        state.selectPart = SelectTeam.allCases[currentIndex + 1]
      }

      return .none
      
    case .swipePrevious:
      guard let selectPart = state.selectPart else { return .none }
      if let currentIndex = SelectTeam.allCases.firstIndex(of: selectPart),
         currentIndex > 0 {
        state.selectPart = SelectTeam.allCases[currentIndex - 1]
      }
      return .none
      
    case .appearSelectDate:
      state.destination = .selectDate(.init())
      return .none
      
    case .closeModal:
      state.destination = nil
      return .none
    }
  }
  
  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {
    case .appearData:
      return .concatenate(
        Effect.run(operation: { send in
          await send(.async(.fetchAttendanceCount))
        }),
        Effect.run(operation: { send in
          await send(.async(.fetchScheduleAttedanceCheck))
        })
      )
      .debounce(id: AttendanceCheckCancel(), for: 0.3, scheduler: mainQueue)
      
    case .fetchAttendanceCount:
      return .run { [nowDate = state.selectAttandanceDate] send in
        let attendanceCountResult = await Result {
          try await attendanceUseCase.attendanceCount(startDate: nowDate.formattedDates())
        }
        
        switch attendanceCountResult {
        case .success(let attendanceCountDTOData):
          if let attendanceCountDTOData = attendanceCountDTOData {
            await send(.inner(.attendanceCountResponse(.success(attendanceCountDTOData))))
          }
          
        case .failure(let error):
          await send(.inner(.attendanceCountResponse(.failure(.encodingError(error.localizedDescription)))))
        }
        
      }
      
    case .filterAttendanceCount(let startDate):
      return .run {  send in
        let attendanceCountResult = await Result {
          try await attendanceUseCase.attendanceCount(startDate: startDate)
        }
        
        switch attendanceCountResult {
        case .success(let attendanceCountDTOData):
          if let attendanceCountDTOData = attendanceCountDTOData {
            await send(.inner(.attendanceCountResponse(.success(attendanceCountDTOData))))
            
            await send(.view(.closeModal))
          }
          
        case .failure(let error):
          await send(.inner(.attendanceCountResponse(.failure(.encodingError(error.localizedDescription)))))
        }
        
      }
      .debounce(id: AttendanceCheckCancel(), for: 0.3, scheduler: mainQueue)

    case .fetchScheduleAttedanceCheck:
      return .run { [startDate = state.selectAttandanceDate] send in
        let attendanceCheckResult = await Result {
          try await scheduleUseCase.filtergetSchedules(startDate: startDate.formattedDates())
        }

        switch attendanceCheckResult {
        case .success(let attendanceCheckData):
          if let attendanceCheckData = attendanceCheckData {
            await send(.inner(.scheduleAttendanceCheckResponse(.success(attendanceCheckData))))
          }

        case .failure(let error):
          await send(.inner(.scheduleAttendanceCheckResponse(.failure(.encodingError(error.localizedDescription)))))
        }


      }
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
    case .attendanceCountResponse(let result):
      switch result {
      case .success(let attendanceCountDTO):
        state.attendanceCountDTOModel = attendanceCountDTO
      case .failure(let error):
        #logNetwork("출석 카운트 조회 에러", error.localizedDescription)
      }
      return .none

    case .scheduleAttendanceCheckResponse(let result):
      switch result {
      case .success(let scheduleAttendanceData):
        let sortedData = scheduleAttendanceData.data.map { schedule in
          let order: [AttendanceType] = [.present, .late, .tbd, .absent]

          let sortedSummary = schedule.attendancesSummary.sorted { lhs, rhs in
            let lhsType = AttendanceType(rawValue: lhs.status) ?? .notAttendance
            let rhsType = AttendanceType(rawValue: rhs.status) ?? .notAttendance
            return order.firstIndex(of: lhsType) ?? 999 < order.firstIndex(of: rhsType) ?? 999
          }

          return ScheduleResponseModel(
            scheduleId: schedule.scheduleId,
            title: schedule.title,
            description: schedule.description,
            startTime: schedule.startTime,
            endTime: schedule.endTime,
            attendancesSummary: sortedSummary
          )
        }

        state.sceheduleAttandanceModel = ScheduleModel(
          code: scheduleAttendanceData.code,
          message: scheduleAttendanceData.message,
          data: sortedData
        )
        let filtered: [AttendancesSummary] = state.sceheduleAttandanceModel?.data.flatMap { schedule in
          schedule.attendancesSummary.filter {
            $0.profile.team.rawValue == state.selectPart?.rawValue
          }
        } ?? []

        #logDebug("filter model", filtered)

      case .failure(let error):
        #logError("출석 목록 조회 실패", error.localizedDescription)
      }
      return .none

    case .fillterAttendance(let team):
      let filteredSchedules = state.sceheduleAttandanceModel?.data.map { schedule in
          let filteredAttendances = schedule.attendancesSummary.filter { item in
            guard let teamEnum = SelectTeam(rawValue: item.profile.team.rawValue) else { return false }
            return teamEnum == team
          }

        return ScheduleResponseModel(
          scheduleId: schedule.scheduleId,
          title: schedule.title,
          description: schedule.description,
          startTime: schedule.startTime,
          endTime: schedule.endTime,
          attendancesSummary: filteredAttendances
        )
      } ?? []


      return .none
    }
  }
}
