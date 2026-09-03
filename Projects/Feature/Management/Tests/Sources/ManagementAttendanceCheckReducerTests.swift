//
//  ManagementAttendanceCheckReducerTests.swift
//  ManagementTests
//
//  Created by DDD on 2026-09-03.
//
//  AttendanceCheck 의 view / async / inner / destination / modal 분기를 TestStore 로 훑는다.
//

import ComposableArchitecture
import Entity
import Testing

@testable import Management

@MainActor
@Suite("ManagementAttendanceCheck")
struct ManagementAttendanceCheckReducerTests {
  // MARK: - View

  @Test("updateDividerWidths 는 받은 너비를 누적해서 병합한다")
  func updateDividerWidthsMergesValues() async {
    var state = AttendanceCheck.State()
    state.dividerWidths = [1: 10]

    let store = TestStore(initialState: state) {
      AttendanceCheck()
    }

    await store.send(.view(.updateDividerWidths([2: 20]))) {
      $0.dividerWidths = [1: 10, 2: 20]
    }
  }

  @Test("tapSelectDate 는 일정 모달을 띄우고 closeModal 은 닫는다")
  func tapSelectDatePresentsScheduleModal() async {
    let store = TestStore(initialState: AttendanceCheck.State()) {
      AttendanceCheck()
    }

    await store.send(.view(.tapSelectDate)) {
      $0.destination = .scheduleModal(.init())
    }

    await store.send(.view(.closeModal)) {
      $0.destination = nil
    }
  }

  @Test("showEditAttendanceModal 은 수정 대상과 관리자 모달을 세팅한다")
  func showEditAttendanceModalStoresTarget() async {
    var state = AttendanceCheck.State()
    state.attendanceStatus = .init(uniqueElements: ManagementSupportFixture.statuses)

    let store = TestStore(initialState: state) {
      AttendanceCheck()
    }

    await store.send(.view(.showEditAttendanceModal(id: 100, userId: "user-1"))) {
      $0.attendanceModal = .adminStatusChangeWithAvailable(
        availableStatuses: ManagementSupportFixture.statuses,
        currentStatus: .attended
      )
      $0.attendanceId = 100
      $0.editAttendanceUserId = "user-1"
    }
  }

  @Test("selectPartButton 은 선택 팀을 바꾸고 출석 조회를 요청한다")
  func selectPartButtonUpdatesTeamAndRequestsAttendance() async {
    let store = TestStore(initialState: AttendanceCheck.State()) {
      AttendanceCheck()
    }

    await store.send(.view(.selectPartButton(selectPart: ManagementSupportFixture.teams[1]))) {
      $0.selectPart = .web1
      $0.selectTeamID = 2
    }

    // scheduleID 가 0 이라 fetchAttendance 는 가드에 걸려 아무 것도 하지 않는다.
    await store.receive(\.async)
  }

  @Test("팀 목록이 비면 스와이프는 아무 일도 하지 않는다")
  func swipeWithoutTeamsDoesNothing() async {
    let store = TestStore(initialState: AttendanceCheck.State()) {
      AttendanceCheck()
    }

    await store.send(.view(.swipeNext))
    await store.send(.view(.swipePrevious))
  }

  @Test("swipeNext 는 다음 팀으로, swipePrevious 는 이전 팀으로 순환한다")
  func swipeCyclesThroughTeams() async {
    var state = AttendanceCheck.State()
    state.attendanceTeam = .init(uniqueElements: ManagementSupportFixture.teams)
    state.selectTeamID = 1

    let store = TestStore(initialState: state) {
      AttendanceCheck()
    }

    await store.send(.view(.swipeNext)) {
      $0.selectPart = .web1
      $0.selectTeamID = 2
    }
    await store.receive(\.async)

    await store.send(.view(.swipePrevious)) {
      $0.selectPart = .ios1
      $0.selectTeamID = 1
    }
    await store.receive(\.async)
  }

  @Test("onAppear 는 최초 1회만 전체 로딩을 돌리고 이후에는 새로고침만 한다")
  func onAppearLoadsOnceThenRefreshes() async {
    let store = TestStore(initialState: AttendanceCheck.State()) {
      AttendanceCheck()
    } withDependencies: {
      $0.attendanceUseCase = ManagementSupportAttendanceUseCase()
      $0.scheduleUseCase = ManagementSupportScheduleUseCase()
      $0.continuousClock = ImmediateClock()
      $0.mainQueue = .immediate
    }
    store.exhaustivity = .off

    await store.send(.view(.onAppear)) {
      $0.selectPart = .unknown
      $0.hasFetchedAttendance = true
    }
    await store.finish()

    #expect(store.state.loading == false)
    #expect(store.state.selectScheduleID == 1)
    #expect(store.state.attendanceTeam.count == 2)
    #expect(store.state.attendanceStatus.count == ManagementSupportFixture.statuses.count)

    await store.send(.view(.onAppear))
    await store.finish()

    #expect(store.state.attendanceCount == ManagementSupportFixture.attendanceCount.attendanceCount)
  }

  // MARK: - Async 가드

  @Test("scheduleID 가 없으면 출석 통계와 출석 목록 조회를 건너뛴다")
  func asyncGuardsSkipWithoutScheduleID() async {
    let store = TestStore(initialState: AttendanceCheck.State()) {
      AttendanceCheck()
    }

    await store.send(.async(.fetchAttendanceCount))
    await store.send(.async(.fetchAttendance))
  }

  @Test("fetchStatus 는 출석 상태 목록을 받아 담는다")
  func fetchStatusStoresStatuses() async {
    let store = TestStore(initialState: AttendanceCheck.State()) {
      AttendanceCheck()
    } withDependencies: {
      $0.attendanceUseCase = ManagementSupportAttendanceUseCase()
    }

    await store.send(.async(.fetchStatus))
    await store.receive(\.inner) {
      $0.attendanceStatus = .init(uniqueElements: ManagementSupportFixture.statuses)
    }
  }

  @Test("fetchSchedule 은 로딩을 켰다가 응답으로 끈다")
  func fetchScheduleTogglesLoading() async {
    let store = TestStore(initialState: AttendanceCheck.State()) {
      AttendanceCheck()
    } withDependencies: {
      $0.scheduleUseCase = ManagementSupportScheduleUseCase()
      $0.attendanceUseCase = ManagementSupportAttendanceUseCase()
      $0.continuousClock = ImmediateClock()
    }
    store.exhaustivity = .off

    await store.send(.async(.fetchSchedule)) {
      $0.loading = true
    }
    await store.finish()

    #expect(store.state.loading == false)
    #expect(store.state.selectScheduleID == 1)
  }

  // MARK: - Inner

  @Test("스케줄 조회 실패는 로딩만 내린다")
  func fetchScheduleFailureStopsLoading() async {
    var state = AttendanceCheck.State()
    state.loading = true

    let store = TestStore(initialState: state) {
      AttendanceCheck()
    }

    await store.send(.inner(.fetchScheduleResponse(.failure(.loadFailed)))) {
      $0.loading = false
    }
  }

  @Test("출석 통계 응답은 참석·지각·결석 수를 채운다")
  func attendanceCountResponseFillsCounts() async {
    let store = TestStore(initialState: AttendanceCheck.State()) {
      AttendanceCheck()
    }

    await store.send(.inner(.attendanceCountResponse(.success(ManagementSupportFixture.attendanceCount)))) {
      $0.attendanceCountModel = ManagementSupportFixture.attendanceCount
      $0.attendanceCount = ManagementSupportFixture.attendanceCount.attendanceCount
      $0.lateCount = ManagementSupportFixture.attendanceCount.lateCount
      $0.absentCount = ManagementSupportFixture.attendanceCount.absentCount
    }
  }

  @Test("출석 통계 실패는 상태를 건드리지 않는다")
  func attendanceCountFailureKeepsState() async {
    let store = TestStore(initialState: AttendanceCheck.State()) {
      AttendanceCheck()
    }

    await store.send(.inner(.attendanceCountResponse(.failure(.loadFailed))))
  }

  @Test("팀 응답은 중복을 제거하고 teamId 순으로 정렬해 첫 팀을 고른다")
  func fetchTeamsResponseDedupesAndSelectsFirstTeam() async {
    let store = TestStore(initialState: AttendanceCheck.State()) {
      AttendanceCheck()
    }

    let duplicated = ManagementSupportFixture.teams + [SelectTeamEntity(teamId: 3, teams: .ios1)]

    await store.send(.inner(.fetchTeamsResponse(.success(duplicated)))) {
      $0.attendanceTeam = .init(uniqueElements: ManagementSupportFixture.teams)
      $0.attendanceByTeam = [1: [], 2: []]
      $0.selectPart = .ios1
      $0.selectTeamID = 1
    }
  }

  @Test("스케줄이 정해진 뒤 팀 응답이 오면 출석 목록까지 이어서 조회한다")
  func fetchTeamsResponseChainsAttendance() async {
    var state = AttendanceCheck.State()
    state.selectScheduleID = 5

    let store = TestStore(initialState: state) {
      AttendanceCheck()
    } withDependencies: {
      $0.attendanceUseCase = ManagementSupportAttendanceUseCase()
    }

    await store.send(.inner(.fetchTeamsResponse(.success(ManagementSupportFixture.teams)))) {
      $0.attendanceTeam = .init(uniqueElements: ManagementSupportFixture.teams)
      $0.attendanceByTeam = [1: [], 2: []]
      $0.selectPart = .ios1
      $0.selectTeamID = 1
    }

    await store.receive(\.async)
    await store.receive(\.inner) {
      $0.attendanceModel = ManagementSupportFixture.attendances
      $0.attendanceByTeam[1] = ManagementSupportFixture.attendances
    }
  }

  @Test("팀 조회 실패는 상태를 건드리지 않는다")
  func fetchTeamsFailureKeepsState() async {
    let store = TestStore(initialState: AttendanceCheck.State()) {
      AttendanceCheck()
    }

    await store.send(.inner(.fetchTeamsResponse(.failure(.loadFailed))))
  }

  @Test("출석 목록 응답은 첫 행의 팀 정보로 선택 파트를 맞춘다")
  func attendanceResponseSyncsSelectedPart() async {
    let store = TestStore(initialState: AttendanceCheck.State()) {
      AttendanceCheck()
    }

    await store.send(.inner(.attendanceResponse(teamId: 1, .success(ManagementSupportFixture.attendances)))) {
      $0.attendanceModel = ManagementSupportFixture.attendances
      $0.attendanceByTeam[1] = ManagementSupportFixture.attendances
      $0.selectPart = .ios1
    }
  }

  @Test("출석 목록 실패는 상태를 건드리지 않는다")
  func attendanceResponseFailureKeepsState() async {
    let store = TestStore(initialState: AttendanceCheck.State()) {
      AttendanceCheck()
    }

    await store.send(.inner(.attendanceResponse(teamId: 1, .failure(.loadFailed))))
  }

  @Test("출석 상태 조회 실패는 상태를 건드리지 않는다")
  func attendanceStatusFailureKeepsState() async {
    let store = TestStore(initialState: AttendanceCheck.State()) {
      AttendanceCheck()
    }

    await store.send(.inner(.attendanceStatusResponse(.failure(.loadFailed))))
  }

  @Test("출석 수정 성공은 통계와 목록을 다시 부른다")
  func editAttendanceSuccessRefetches() async {
    let store = TestStore(initialState: AttendanceCheck.State()) {
      AttendanceCheck()
    }
    store.exhaustivity = .off

    await store.send(.inner(.editAttendanceResponse(.success(ManagementSupportFixture.editAttendance)))) {
      $0.editAttendance = ManagementSupportFixture.editAttendance
    }
    await store.finish()
  }

  @Test("rejected 로 거절되면 서버 문구를 그대로 알림에 싣는다")
  func editAttendanceRejectedShowsServerMessage() async {
    let store = TestStore(initialState: AttendanceCheck.State()) {
      AttendanceCheck()
    }

    await store.send(.inner(.editAttendanceResponse(.failure(.rejected("출석일이 아닙니다"))))) {
      $0.alert = AlertState {
        TextState("알림")
      } actions: {
        ButtonState(action: .confirmTapped) {
          TextState("확인")
        }
      } message: {
        TextState("출석일이 아닙니다")
      }
    }
  }

  @Test("그 밖의 수정 실패는 수정 실패 알럿을 띄운다")
  func editAttendanceFailureShowsGenericAlert() async {
    let store = TestStore(initialState: AttendanceCheck.State()) {
      AttendanceCheck()
    }

    await store.send(.inner(.editAttendanceResponse(.failure(.updateFailed)))) {
      $0.alert = AlertState {
        TextState("출석 수정 실패")
      } actions: {
        ButtonState(action: .confirmTapped) {
          TextState("확인")
        }
      } message: {
        TextState(AttendanceError.updateFailed.errorDescription ?? "")
      }
    }
  }

  @Test("알럿 확인은 알럿을 닫는다")
  func alertConfirmDismissesAlert() async {
    var state = AttendanceCheck.State()
    state.alert = AlertState {
      TextState("출석 수정 실패")
    } actions: {
      ButtonState(action: .confirmTapped) {
        TextState("확인")
      }
    }

    let store = TestStore(initialState: state) {
      AttendanceCheck()
    }

    await store.send(.scope(.alert(.presented(.confirmTapped)))) {
      $0.alert = nil
    }
  }

  // MARK: - Destination / Modal

  @Test("일정 모달이 날짜를 확정하면 모달을 닫고 해당 스케줄을 다시 조회한다")
  func scheduleModalDelegateUpdatesSelectedSchedule() async {
    var state = AttendanceCheck.State()
    state.destination = .scheduleModal(.init())

    let store = TestStore(initialState: state) {
      AttendanceCheck()
    } withDependencies: {
      $0.attendanceUseCase = ManagementSupportAttendanceUseCase()
    }
    store.exhaustivity = .off

    let selected = EntityFixtureSchedule.value
    await store.send(
      .destination(.presented(.scheduleModal(.delegate(.selectScheduleCompleted(selectedSchedule: selected)))))
    ) {
      $0.selectAttendanceDate = selected.toDate()!
      $0.selectScheduleID = selected.id
      $0.destination = nil
    }
    await store.finish()
  }

  @Test("모달에서 상태를 확정하면 모달을 닫고 수정 요청을 보낸다")
  func attendanceModalConfirmSendsEdit() async {
    var state = AttendanceCheck.State()
    state.attendanceModal = .adminStatusChangeWithAvailable(
      availableStatuses: ManagementSupportFixture.statuses
    )
    state.attendanceId = 100
    state.editAttendanceUserId = "user-1"
    state.selectScheduleID = 5

    let store = TestStore(initialState: state) {
      AttendanceCheck()
    } withDependencies: {
      $0.attendanceUseCase = ManagementSupportAttendanceUseCase()
    }
    store.exhaustivity = .off

    await store.send(.scope(.attendanceModal(.presented(.confirmTapped(.late))))) {
      $0.attendanceModal = nil
    }
    await store.finish()

    #expect(store.state.editAttendance == ManagementSupportFixture.editAttendance)
  }

  @Test("모달 취소는 모달만 닫는다")
  func attendanceModalCancelClosesModal() async {
    var state = AttendanceCheck.State()
    state.attendanceModal = .adminStatusChangeWithAvailable(
      availableStatuses: ManagementSupportFixture.statuses
    )

    let store = TestStore(initialState: state) {
      AttendanceCheck()
    }

    await store.send(.scope(.attendanceModal(.presented(.cancelTapped)))) {
      $0.attendanceModal = nil
    }
  }

  @Test("모달 dismiss 는 상태를 비운다")
  func attendanceModalDismissClearsState() async {
    var state = AttendanceCheck.State()
    state.attendanceModal = .adminStatusChangeWithAvailable(
      availableStatuses: ManagementSupportFixture.statuses
    )

    let store = TestStore(initialState: state) {
      AttendanceCheck()
    }

    await store.send(.scope(.attendanceModal(.dismiss))) {
      $0.attendanceModal = nil
    }
  }
}
