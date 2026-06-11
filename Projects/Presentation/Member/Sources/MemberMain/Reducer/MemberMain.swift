//
//  MemberMain.swift
//  Presentation
//
//  Created by 홍은표 on 1/2/25.
//

import Foundation

import Entity
import LogMacro
import Shareds
import UseCase

import ComposableArchitecture

@Reducer
public struct MemberMain {
  public init() {}

  // 멤버 홈 탭 (일정은 운영진 전용이라 제외)
  public enum HomeTab: String, CaseIterable, Equatable {
    case attendance
    case vote

    public var title: String {
      switch self {
      case .attendance: return "출석현황"
      case .vote: return "투표"
      }
    }
  }

  @ObservableState
  public struct State: Equatable {
    var member: ProfileEntity?

    var selectedHomeTab: HomeTab = .attendance
    var isExpandedDropDown: Bool = false

    @ObservationStateIgnored
    var didAppear: Bool = false

    // 출석 현황
    var startDate: String = ""
    var endDate: String = ""
    var presentCount: Int = .zero
    var lateCount: Int = .zero
    var absentCount: Int = .zero
    var showAttendanceWarningIcon: Bool = false
    var isPresentAttendanceWarningAlert: Bool = false

    // 일정표
    var schedules: IdentifiedArrayOf<ScheduleModel> = .init(uniqueElements: [])

    public init() {}
  }

  public enum Action: ViewAction, BindableAction, FeatureAction {
    case binding(BindingAction<State>)
    case view(View)
    case inner(InnerAction)
    case async(AsyncAction)
    case navigation(NavigationAction)
  }

  @CasePathable
  public enum View {
    case onAppear
    case didTapAbesentButton
    case didTapDismissAlertButton
    case toggleDropDown
    case selectHomeTab(HomeTab)
  }

  public enum AsyncAction: Equatable {
    case fetchCurrentUser
    case fetchAttendances
    case fetchSchedule
  }

  public enum InnerAction: Equatable {
    case onFetchUserResponse(Result<ProfileEntity, ProfileError>)
    case onFetchAttendanceSummaryResponse(Result<AttendanceSummaryResponse, AttendanceError>)
    case onFetchSchedulesResponse(Result<[ScheduleModel], ScheduleError>)
    case onResume
  }

  public enum NavigationAction: Equatable {
    case routeToQRCode
    case routeToProfile
  }

  @Reducer(state: .equatable)
  public enum Destination {
    case qrcode(MemberQRCode)
  }

  @Dependency(ProfileUseCaseImpl.self) var profileUseCase
  @Dependency(AttendanceUseCaseImpl.self) var attendanceUseCase
  @Dependency(\.fetchMyAttendancesUseCase) var fetchMyAttendancesUseCase
  @Dependency(\.fetchMySchedulesUseCase) var fetchMySchedulesUseCase

  public var body: some Reducer<State, Action> {
    BindingReducer()

    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case let .view(action):
        return handleViewAction(state: &state, action: action)

      case let .inner(action):
        return handleInnerAction(state: &state, action: action)

      case let .async(action):
        return handleAsyncAction(state: &state, action: action)

      case let .navigation(action):
        return handleNavigationAction(state: &state, action: action)
      }
    }
  }
}

extension MemberMain {
  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
    case .onAppear:
      guard !state.didAppear else {
        return .none
      }

      state.didAppear = true

      return .merge(
        .run { await $0(.async(.fetchCurrentUser)) },
        .run { await $0(.async(.fetchSchedule)) }
      )

    case .didTapAbesentButton:
      guard state.showAttendanceWarningIcon else {
        return .none
      }

      state.isPresentAttendanceWarningAlert = true
      return .none

    case .didTapDismissAlertButton:
      state.isPresentAttendanceWarningAlert = false
      return .none

    case .toggleDropDown:
      state.isExpandedDropDown.toggle()
      return .none

    case let .selectHomeTab(tab):
      state.selectedHomeTab = tab
      state.isExpandedDropDown = false
      return .none
    }
  }

  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {
    case let .onFetchUserResponse(result):
      switch result {
      case let .success(member):
        state.member = member
        #logDebug("Succeed Fetch User Profile", member)
        return .none

      case let .failure(error):
        state.member = nil
        #logError("Failed Fetch User Profile", error)
        return .none
      }

    case let .onFetchAttendanceSummaryResponse(result):
      switch result {
      case let .success(counts):
        state.presentCount = counts.totalAttended
        state.lateCount = counts.totalLate
        state.absentCount = counts.totalAbsent
        state.showAttendanceWarningIcon = state.absentCount > 0
        #logDebug("Succeed Fetch Attendance Counts", counts)
        return .none

      case let .failure(error):
        #logError("Failed Fetch Count: ", error)
        return .none
      }

    case let .onFetchSchedulesResponse(result):
      switch result {
      case let .success(schedules):
        state.schedules = .init(uniqueElements: schedules)

        // TODO: - 추후 기수 활동 기간 API 필요
        if let start = schedules.first, let end = schedules.last {
          state.startDate = "2026.\(start.month).\(start.day)"
          state.endDate = "2026.\(end.month).\(end.day)"
        }

        #logDebug("Succeed Fetch Schedules: ", schedules)
        return .none

      case let .failure(error):
        #logError("Failed Fetch Schedules", error)
        return .none
      }

    case .onResume:
      return .concatenate(
        .run { await $0(.async(.fetchCurrentUser)) },
        .run { await $0(.async(.fetchSchedule)) }
      )
    }
  }

  private func handleAsyncAction(
    state _: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {
    case .fetchCurrentUser:
      return .run { send in
        let result = await Result {
          try await profileUseCase.getProfile()
        }

        switch result {
        case let .success(member):
          await send(.inner(.onFetchUserResponse(.success(member))))
          await send(.async(.fetchAttendances))

        case let .failure(error):
          let error = ProfileError.from(error)
          await send(.inner(.onFetchUserResponse(.failure(error))))
        }
      }

    case .fetchAttendances:
      return .run { send in
        let result = await Result {
          try await fetchMyAttendancesUseCase.execute()
        }

        switch result {
        case let .success(counts):
          await send(.inner(.onFetchAttendanceSummaryResponse(.success(counts))))

        case let .failure(error):
          let error = AttendanceError.from(error)
          await send(.inner(.onFetchAttendanceSummaryResponse(.failure(error))))
        }
      }

    case .fetchSchedule:
      return .run { send in
        let result = await Result {
          try await fetchMySchedulesUseCase.execute()
        }

        switch result {
        case let .success(schedules):
          let schedules = schedules.map { $0.toPresentation() }
          await send(.inner(.onFetchSchedulesResponse(.success(schedules))))

        case let .failure(error):
          let error = ScheduleError.from(error)
          await send(.inner(.onFetchSchedulesResponse(.failure(error))))
        }
      }
    }
  }

  private func handleNavigationAction(
    state _: inout State,
    action: NavigationAction
  ) -> Effect<Action> {
    switch action {
    case .routeToQRCode:
      return .none

    case .routeToProfile:
      return .none
    }
  }
}

private extension AttendanceMyScheduleResponse {
  func toPresentation() -> ScheduleModel {
    return .init(
      id: id,
      title: name,
      description: desc,
      month: month,
      day: day,
      status: .init(rawValue: status) ?? .none
    )
  }
}
