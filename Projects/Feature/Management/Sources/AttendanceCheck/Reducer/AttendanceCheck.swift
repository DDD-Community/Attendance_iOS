//
//  AttendanceCheck.swift
//  Presentation
//
//  Created by DDD on 1/16/25.
//

import DDDCoreLogger
import Foundation

import DDDSharedUI

import ComposableArchitecture
import AttendanceDomainInterface
import ScheduleDomainInterface

@Reducer
public struct AttendanceCheck {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    
    var selectAttendanceDate: Date = .now
    var selectAttendanceDateMonth: Date = .now
    var selectPart: SelectTeams? = .web1
    @Shared(.inMemory("UserSession")) var userSession: UserSession = .empty
    
    var selectTeamID: Int = 0
    
    var dividerWidths: [Int: CGFloat] = [:]
    
    var isLoading: Bool = false
    var loading: Bool = false
    var attendanceCount: Int = .zero
    var lateCount: Int = .zero
    var absentCount: Int = .zero
    var hasFetchedAttendance: Bool = false
    
    @Presents var destination: Destination.State?
    var scheduleModel: IdentifiedArrayOf<Schedule> = .init(uniqueElements: [])
    var selectScheduleID: Int = 0
    var attendanceCountModel : AttendanceCount?
    var attendanceTeam: IdentifiedArrayOf<SelectTeamEntity> = .init(uniqueElements: [])
    var attendanceModel: [Attendance] = []
    var attendanceByTeam: [Int: [Attendance]] = [:]
    var attendanceStatus: IdentifiedArrayOf<AttendanceStatus> = .init(uniqueElements: [])
    var editAttendance: EditAttendance?
    var attendanceId: Int? = nil
    var editAttendanceUserId: String = ""
    
    @Presents var attendanceModal: AttendanceModalState<AttendanceModalAction>?
    @Presents public var alert: AlertState<AlertAction>?
    
    
    public init() {
      
    }
  }
  
  public enum Action: ViewAction, BindableAction {
    case destination(PresentationAction<Destination.Action>)
    case binding(BindingAction<State>)
    case view(View)
    case async(AsyncAction)
    case inner(InnerAction)
    case delegate(DelegateAction)
    case scope(ScopeAction)
    
  }
  
  @Reducer(state: .equatable)
  public enum Destination {
    case scheduleModal(ScheduleModal)
  }
  
  // MARK: - ViewAction
  @CasePathable
  public enum View {
    case onAppear
    case selectPartButton(selectPart: SelectTeamEntity)
    case swipeNext
    case swipePrevious
    case closeModal
    case tapSelectDate
    case showEditAttendanceModal(id: Int?, userId: String)
    case refreshData // 수동 새로고침
    case updateDividerWidths([Int: CGFloat])
  }
  
  // MARK: - AsyncAction 비동기 처리 액션
  
  public enum AsyncAction: Equatable {
    case fetchSchedule
    case fetchAttendanceCount
    case fetchTeams
    case fetchAttendance
    case fetchStatus
    case editAttendance(userid: String, status: AttendanceStatus)
  }
  
  // MARK: - 앱내에서 사용하는 액션
  public enum InnerAction: Equatable {
    case fetchScheduleResponse(Result<[Schedule], ScheduleError>)
    case attendanceCountResponse(Result<AttendanceCount, AttendanceError>)
    case fetchTeamsResponse(Result<[SelectTeamEntity], AttendanceError>)
    case attendanceResponse(teamId: Int, Result<[Attendance], AttendanceError>)
    case attendanceStatusResponse(Result<[AttendanceStatus], AttendanceError>)
    case editAttendanceResponse(Result<EditAttendance, AttendanceError>)
  }
  
  // MARK: - DelegateAction
  public enum DelegateAction: Equatable {
    
  }
  
  @CasePathable
  public enum AlertAction {
    case confirmTapped
  }
  
  @CasePathable
  public enum ScopeAction: Equatable {
    case alert(PresentationAction<AlertAction>)
    case attendanceModal(PresentationAction<AttendanceModalAction>)
  }
  
  nonisolated enum CancelID: Hashable {
    case fetchSchedule
    case fetchAttendanceCount
    case fetchTeams
    case fetchAttendance
    case fetchStatus
    case editAttendance
  }
  
  
  @Dependency(\.attendanceUseCase) var attendanceUseCase
  @Dependency(\.scheduleUseCase) var scheduleUseCase
  @Dependency(\.continuousClock) var clock
  @Dependency(\.mainQueue) var mainQueue
  
  public var body: some Reducer<State, Action> {
    BindingReducer()
    
    Reduce { state, action in
      switch action {
      case .binding(_):
        // BindingReducer가 자동으로 처리
        return .none
        
      case .view(let viewAction):
        return handleViewAction(state: &state, action: viewAction)
        
      case .async(let asyncAction):
        return handleAsyncAction(state: &state, action: asyncAction)
        
      case .inner(let innerAction):
        return handleInnerAction(state: &state, action: innerAction)
        
      case .delegate(let delegateAction):
        return handleDelegateAction(state: &state, action: delegateAction)
        
      case .destination(let destinationAction):
        return handleDestinationAction(state: &state, action: destinationAction)
        
      case .scope(let scopeAction):
        switch scopeAction {
        case .alert:
          return .none
          
        case .attendanceModal(let action):
          return handleAttendanceModalAction(state: &state, action: action)
        }
        
      }
    }
    .ifLet(\.$destination, action: \.destination)
    .ifLet(\.$alert, action: \.scope.alert)
    .ifLet(\.$attendanceModal, action: \.scope.attendanceModal) {
      AttendanceModal()
    }
  }
}

extension AttendanceCheck {
  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
    case .onAppear:
      // 첫 진입 시에만 전체 데이터 로드, 이후에는 중요한 데이터만 새로고침
      state.selectPart = state.userSession.selectTeam
      if !state.hasFetchedAttendance {
        state.hasFetchedAttendance = true
        return .concatenate(
          .run { await $0(.async(.fetchSchedule)) }, // 성공시 fetchAttendanceCount와 fetchTeams 자동 호출
          .run { await $0(.async(.fetchStatus)) },
        )
      } else {
        return .concatenate(
          .run { await $0(.view(.refreshData)) },
        )
      }
      
    case .refreshData:
      // 수동 새로고침: 실시간 데이터만 다시 가져옴 (스케줄은 제외)
      return .merge(
        .run { await $0(.async(.fetchAttendanceCount)) },
        .run { await $0(.async(.fetchTeams)) },
        .run { await $0(.async(.fetchStatus)) }
      )

    case .updateDividerWidths(let widths):
      for (key, width) in widths {
        state.dividerWidths[key] = width
      }
      return .none
      
    case .selectPartButton(let selectPart):
      state.selectPart = selectPart.teams
      state.selectTeamID = selectPart.teamId
      return .send(.async(.fetchAttendance))
      
    case .swipeNext:
      let orderedTeams = orderedAttendanceTeams(from: state.attendanceTeam)
      
      guard !orderedTeams.isEmpty else {
        return .none
      }
      
      let currentIndex = orderedTeams.firstIndex { $0.teamId == state.selectTeamID } ?? 0
      let nextIndex = (currentIndex + 1) % orderedTeams.count
      
      updateSelectedTeam(state: &state, team: orderedTeams[nextIndex])
      return .send(.async(.fetchAttendance))
      
    case .swipePrevious:
      let orderedTeams = orderedAttendanceTeams(from: state.attendanceTeam)
      
      guard !orderedTeams.isEmpty else {
        return .none
      }
      
      let currentIndex = orderedTeams.firstIndex { $0.teamId == state.selectTeamID } ?? 0
      let prevIndex = (currentIndex - 1 + orderedTeams.count) % orderedTeams.count
      
      updateSelectedTeam(state: &state, team: orderedTeams[prevIndex])
      return .send(.async(.fetchAttendance))
      
      
    case .tapSelectDate:
      state.destination = .scheduleModal(.init())
      return .none
      
    case .closeModal:
      state.destination = nil
      return .none
      
    case .showEditAttendanceModal(let id, let userid):
      state.attendanceModal = .adminStatusChangeWithAvailable(
        availableStatuses: Array(state.attendanceStatus),
        currentStatus: .attended
      )
      state.attendanceId = id
      state.editAttendanceUserId = userid
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
        try await clock.sleep(for: .seconds(0.8))
        return await send(.inner(.fetchScheduleResponse(scheduleResult)))
        
      }
      .cancellable(id: CancelID.fetchSchedule, cancelInFlight: true)
      
    case .fetchAttendanceCount:
      let scheduleID = state.selectScheduleID
      
      // scheduleId가 유효한지 확인
      guard scheduleID > 0 else {
        DDDLogger.debug("fetchAttendanceCount 건너뜀: scheduleId: \(scheduleID)", category: .attendance)
        return .none
      }
      
      return .run { send in
        let attendanceResult = await Result {
          try await attendanceUseCase.adminAttendanceCount(scheduleId: scheduleID)
        }
          .mapError(AttendanceError.from)
        return await send(.inner(.attendanceCountResponse(attendanceResult)))
      }
      .cancellable(id: CancelID.fetchAttendanceCount, cancelInFlight: true)
      
      
    case .fetchTeams:
      return .run { send in
        let teamResult = await Result {
          try await attendanceUseCase.fetchAttendanceTeams()
        }
          .mapError(AttendanceError.from)
        return await send(.inner(.fetchTeamsResponse(teamResult)))
      }
      .cancellable(id: CancelID.fetchTeams, cancelInFlight: true)
      
    case .fetchAttendance:
      let scheduleId = state.selectScheduleID
      let teamId = state.selectTeamID
      
      // scheduleId와 teamId가 유효한지 확인
      guard scheduleId > 0, teamId > 0 else {
        DDDLogger.debug("fetchAttendance 건너뜀: scheduleId: \(scheduleId), teamId: \(teamId)", category: .attendance)
        return .none
      }
      
      return .run { send in
        let attendanceResult = await Result {
          try await attendanceUseCase.sessionAttendance(scheduleId: scheduleId, teamId: teamId)
        }
          .mapError(AttendanceError.from)
        return await send(.inner(.attendanceResponse(teamId: teamId, attendanceResult)))
      }
      .cancellable(id: CancelID.fetchAttendance, cancelInFlight: true)
      
    case .fetchStatus:
      return .run { send in
        let statusResult = await Result {
          try await attendanceUseCase.fetchStatus()
        }
          .mapError(AttendanceError.from)
        return await send(.inner(.attendanceStatusResponse(statusResult)))
        
      }
      .cancellable(id: CancelID.fetchStatus, cancelInFlight: true)
      
    case .editAttendance(let userid, let status):
      return .run {  [
        attendanceId = state.attendanceId,
        scheduleId = state.selectScheduleID
      ] send in
        let editAttendanceResult = await Result {
          let input = EditAttendanceInput(
            attendanceId: attendanceId,
            scheduleId: scheduleId,
            status: status,
            userId: userid
          )
          return try await attendanceUseCase.editAttendance(input: input)
        }
          .mapError(AttendanceError.from)
        
        return await send(.inner(.editAttendanceResponse(editAttendanceResult)))
      }
      .cancellable(id: CancelID.editAttendance, cancelInFlight: true)
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
        state.selectScheduleID = closestScheduleId(from: schedules)
        ?? schedules.first?.id
        ?? state.selectScheduleID
        
        // 스케줄이 설정된 후 출석 통계 및 팀 정보 가져오기
        return .merge(
          .send(.async(.fetchAttendanceCount)),
          .send(.async(.fetchTeams)) // team 설정 후 fetchAttendance 자동 호출됨
        )
        
      case .failure(let error):
        DDDLogger.error("스케줄 조회 실패: \(error.localizedDescription)", category: .network)
        state.loading = false
        return .none
      }
      
    case .attendanceCountResponse(let result):
      switch result {
      case .success(let data):
        state.attendanceCountModel = data
        state.attendanceCount = data.attendanceCount
        state.lateCount = data.lateCount
        state.absentCount = data.absentCount
        
      case .failure(let error):
        DDDLogger.error("기수 출석 현황 조회 실패: \(error.localizedDescription)", category: .network)
        
      }
      return .none
      
    case .fetchTeamsResponse(let result):
      switch result {
      case .success(let data):
        var seen: Set<SelectTeams> = []
        let uniqueTeams = data.filter { seen.insert($0.teams).inserted }
        let orderedTeams = uniqueTeams.sorted { $0.teamId < $1.teamId }
        state.attendanceTeam = .init(uniqueElements: orderedTeams)
        for team in orderedTeams {
          if state.attendanceByTeam[team.teamId] == nil {
            state.attendanceByTeam[team.teamId] = []
          }
        }
        if let userTeam = orderedTeams.first(where: { $0.teams == state.userSession.selectTeam }) {
          state.selectPart = userTeam.teams
          state.selectTeamID = userTeam.teamId
        } else if let firstTeam = orderedTeams.first {
          state.selectPart = firstTeam.teams
          state.selectTeamID = firstTeam.teamId
        }
        
        // team 설정 후 출석 데이터 가져오기 (scheduleId가 유효한 경우에만)
        if state.selectScheduleID > 0 {
          return .send(.async(.fetchAttendance))
        } else {
          return .none
        }
        
      case .failure(let error):
        DDDLogger.error("기수 팀 조회 실패: \(error.localizedDescription)", category: .network)
        return .none
      }
      
    case .attendanceResponse(let teamId, let result):
      switch result {
      case .success(let data):
        state.attendanceModel = data
        state.attendanceByTeam[teamId] = data
        
        // 특정 팀 데이터를 받았을 때 해당 팀으로 selectPart 변경
        if let firstAttendance = data.first,
           let teamEntity = firstAttendance.selectTeamEntity,
           teamEntity != .unknown {
          state.selectPart = teamEntity
          DDDLogger.debug("[AttendanceCheck] Updated selectPart to: \(teamEntity.rawValue)", category: .attendance)
        }
        
      case .failure(let error):
        DDDLogger.error("기수 출석 현황 조회 실패: \(error.localizedDescription)", category: .network)
      }
      return .none
      
    case .attendanceStatusResponse(let result):
      switch result {
      case .success(let data):
        state.attendanceStatus = .init(uniqueElements: data)
      case .failure(let error):
        DDDLogger.error("출석 현황 조회 실패: \(error.localizedDescription)", category: .attendance)
      }
      return .none
      
    case .editAttendanceResponse(let result):
      switch result {
      case .success(let data):
        state.editAttendance = data
        return .merge(
          .run { await $0(.async(.fetchAttendanceCount)) },
          .run { await $0(.async(.fetchAttendance)) }
        )
      case .failure(let error):
        DDDLogger.error("출석 현황 수정 실패: \(error.localizedDescription)", category: .attendance)
        
        // 서버에서 온 사용자 친화적 메시지 사용
        let alertTitle: String
        let alertMessage: String
        
        // 전송 실패는 도메인이 구분하지 않으므로 서버가 준 거절 사유만 따로 보여준다.
        switch error {
        case let .rejected(message):
          alertTitle = "알림"
          alertMessage = message
        default:
          alertTitle = "출석 수정 실패"
          alertMessage = error.errorDescription ?? "출석 상태 수정에 실패했습니다. 다시 시도해주세요."
        }
        
        state.alert = AlertState {
          TextState(alertTitle)
        } actions: {
          ButtonState(action: .confirmTapped) {
            TextState("확인")
          }
        } message: {
          TextState(alertMessage)
        }
      }
      return .none
    }
  }
  
  
  private func handleDestinationAction(
    state: inout State,
    action: PresentationAction<Destination.Action>
  ) -> Effect<Action> {
    switch action {
    case .presented(.scheduleModal(.delegate(.selectScheduleCompleted(let selectedSchedule)))):
      if let selectedDate = selectedSchedule.toDate() {
        state.selectAttendanceDate = selectedDate
        state.selectScheduleID = selectedSchedule.id
        DDDLogger.debug("날짜 업데이트됨: 새로운 날짜: \( state.selectScheduleID)", category: .attendance)
      } else {
        DDDLogger.error("날짜 변환 실패: 입력: year=\(selectedSchedule.year), month=\(selectedSchedule.month), day=\(selectedSchedule.day)", category: .attendance)
      }
      
      state.destination = nil
      
      // 새로운 스케줄 선택시 해당 스케줄의 출석 데이터를 새로 가져오기
      return .merge(
        .send(.async(.fetchAttendanceCount)), // 새 스케줄의 출석 통계
        .send(.async(.fetchAttendance)) // 새 스케줄의 출석 리스트
      )
      
    default:
      return .none
    }
  }
  
  private func handleAttendanceModalAction(
    state: inout State,
    action: PresentationAction<AttendanceModalAction>
  ) -> Effect<Action> {
    switch action {
    case .presented(let attendanceModalAction):
      switch attendanceModalAction {
      case .binding(_):
        return .none
        
      case .confirmTapped(let status):
        state.attendanceModal = nil
        // API 호출 예시
        return .run { [
          userid = state.editAttendanceUserId
        ] send in
          await send(.async(.editAttendance(userid: userid, status: status)))
        }
        
      case .cancelTapped:
        state.attendanceModal = nil
        return .none
      }
      
    case .dismiss:
      return .none
    }
  }
}

private extension AttendanceCheck {
  func orderedAttendanceTeams(
    from teams: IdentifiedArrayOf<SelectTeamEntity>
  ) -> [SelectTeamEntity] {
    teams.sorted { $0.teamId < $1.teamId }
  }
  
  func updateSelectedTeam(
    state: inout State,
    team: SelectTeamEntity
  ) {
    state.selectPart = team.teams
    state.selectTeamID = team.teamId
  }
  
  
  func todayScheduleId(
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
  
  /// 현재 날짜와 가장 가까운 스케줄 ID를 반환
  /// 1. 오늘 날짜의 스케줄이 있으면 우선 반환
  /// 2. 절대적 시간 거리가 가장 가까운 스케줄 선택 (과거/미래 구분 없이)
  func closestScheduleId(
    from schedules: [Schedule],
    now: Date = Date(),
    timeZone: TimeZone = .init(identifier: "Asia/Seoul")!
  ) -> Int? {
    var cal = Calendar(identifier: .gregorian)
    cal.timeZone = timeZone
    
    let today = cal.startOfDay(for: now)
    
    // 오늘 날짜의 스케줄이 있으면 우선 반환
    if let todayId = todayScheduleId(from: schedules, now: now, timeZone: timeZone) {
      return todayId
    }
    
    // 모든 스케줄을 절대적 시간 거리 기준으로 정렬
    let closestSchedule = schedules
      .compactMap { schedule -> (Schedule, Date, TimeInterval)? in
        guard let scheduleDate = schedule.toDate(timeZone: timeZone) else { return nil }
        let scheduleDay = cal.startOfDay(for: scheduleDate)
        
        // 오늘과 같은 날짜는 제외 (이미 위에서 처리됨)
        guard scheduleDay != today else { return nil }
        
        let timeInterval = abs(scheduleDay.timeIntervalSince(today))
        return (schedule, scheduleDate, timeInterval)
      }
      .min(by: { $0.2 < $1.2 }) // 절대적 시간 거리 기준으로 가장 가까운 것 선택
    
    return closestSchedule?.0.id
  }
}
