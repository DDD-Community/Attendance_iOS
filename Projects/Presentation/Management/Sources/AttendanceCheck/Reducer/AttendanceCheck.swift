//
//  AttendanceCheck.swift
//  Presentation
//
//  Created by Wonji Suh  on 1/16/25.
//

import Foundation

import Shareds

import ComposableArchitecture
import LogMacro
import UseCase
import Entity

@Reducer
public struct AttendanceCheck {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    
    var selectAttendanceDate: Date = .now
    var selectAttendanceDateMonth: Date = .now
    var selectPart: SelectTeam? = .web1
    
    var dividerWidths: [SelectTeam: CGFloat] = [:]
    
    var isLoading: Bool = false
    var loading: Bool = false
    var attendanceCount: Int = .zero
    var lateCount: Int = .zero
    var absentCount: Int = .zero
    
    @Presents var destination: Destination.State?
    var scheduleModel: IdentifiedArrayOf<Schedule> = .init(uniqueElements: [])
    var selectScheduleID: Int = 0
    var attendanceCountModel : AttendanceCount?

//    @Shared(.inMemory("Member")) var userSignUpMember: Member = .init()
    
//    var attendanceCountDTOModel: AttendanceCountResponseModel?
//    var attendCheckModel: AttendanceListModel?

    
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
    case scheduleModal(ScheduleModal)
  }
  
  // MARK: - ViewAction
  @CasePathable
  public enum View {
    case onAppear
    case selectPartButton(selectPart: SelectTeam)
    case swipeNext
    case swipePrevious
    case appearSelectDate
    case closeModal
    case tapSelectDate
  }
  
  // MARK: - AsyncAction 비동기 처리 액션

  public enum AsyncAction: Equatable {
    case fetchSchedule
    case fetchAttendanceCount
//    case filterAttendanceCount(startDate: String)
//    case fetchScheduleAttendanceCheck
  }
  
  // MARK: - 앱내에서 사용하는 액션
  public enum InnerAction: Equatable {
    case fetchScheduleResponse(Result<[Schedule], ScheduleError>)
    case AttendanceCountResponse(Result<AttendanceCount, ScheduleError>)

  }
  
  // MARK: - NavigationAction
  public enum NavigationAction: Equatable {

  }
  
  nonisolated enum CancelID: Hashable {
    case fetchSchedule
  }


  @Dependency(\.attendanceUseCase) var attendanceUseCase
  @Dependency(\.scheduleUseCase) var scheduleUseCase
  @Dependency(\.continuousClock) var clock
  @Dependency(\.mainQueue) var mainQueue
  
  public var body: some Reducer<State, Action> {
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

        case .destination(let destinationAction):
         return handleDestinationAction(state: &state, action: destinationAction)
      }
    }
    .ifLet(\.$destination, action: \.destination)
  }
}

extension AttendanceCheck {
  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
      case .onAppear:
        return .concatenate(
          .run { await $0(.async(.fetchSchedule)) },
          .run { await $0(.async(.fetchAttendanceCount)) },
        )

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

      case .tapSelectDate:
        #logDebug("스케줄 모달 열기", "ScheduleModal destination 설정")
        state.destination = .scheduleModal(.init())
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
      case .fetchSchedule:
          state.loading = true
        return .run { send in
          let scheduleResult = await Result {
            try await scheduleUseCase.getSchedule()
          }
            .mapError(ScheduleError.from)
          try await clock.sleep(for: .seconds(2))
          return await send(.inner(.fetchScheduleResponse(scheduleResult)))

        }
        .cancellable(id: CancelID.fetchSchedule, cancelInFlight: true)

      case .fetchAttendanceCount:
        return .run { [
          scheduleID = state.selectScheduleID
        ]send in
          let attendanceResult = await Result {
            try await attendanceUseCase.adminAttendanceCount(scheduleId: scheduleID)
          }
            .mapError(ScheduleError.from)
          return await send(.inner(.AttendanceCountResponse(attendanceResult)))
        }
    }
  }

  private func handleNavigationAction(
    state: inout State,
    action: NavigationAction
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
            state.selectScheduleID = todayScheduleId(from: schedules) ?? .zero

          case .failure(let error):
            #logNetwork("스케줄 조회 실패", error.localizedDescription ?? "알 수 없는 오류")
            state.loading = false
        }
        return .none


      case .AttendanceCountResponse(let result):
        switch result {
          case .success(let data):
            state.attendanceCountModel = data
            state.attendanceCount = data.attendanceCount
            state.lateCount = data.lateCount
            state.absentCount = data.absentCount

          case .failure(let error):
            #logNetwork("기수 출석 현황 조회 실패", error.localizedDescription)

        }
        return .none
    }
  }

  private func todayScheduleId(
    from schedules: [Schedule],
    now: Date = Date(),
    timeZone: TimeZone = .init(identifier: "Asia/Seoul")!
  ) -> Int? {
    var cal = Calendar(identifier: .gregorian)
    cal.timeZone = timeZone

    let comps = cal.dateComponents([.year, .month, .day], from: now)
    guard let y = comps.year, let m = comps.month, let d = comps.day else { return nil }

    return schedules.first(where: { $0.year == y && $0.month == m && $0.day == d })?.id
  }

  private func handleDestinationAction(
    state: inout State,
    action: PresentationAction<Destination.Action>
  ) -> Effect<Action> {
    switch action {
      case .presented(.scheduleModal(.navigation(.selectScheduleCompleted(let selectedSchedule)))):
        if let selectedDate = selectedSchedule.toDate() {
          state.selectAttendanceDate = selectedDate
          state.selectScheduleID = selectedSchedule.id
          #logDebug("날짜 업데이트됨", "새로운 날짜: \( state.selectScheduleID)")
        } else {
          #logError(
            "날짜 변환 실패",
            "입력: year=\(selectedSchedule.year), month=\(selectedSchedule.month), day=\(selectedSchedule.day)"
          )
        }

        state.destination = nil

        return .run { send in
          try await clock.sleep(for: .milliseconds(100))
            await send(.async(.fetchAttendanceCount))
        }

      default:
        return .none
    }
  }
}
