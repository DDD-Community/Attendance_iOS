//
//  MemberMain.swift
//  Presentation
//
//  Created by 홍은표 on 1/2/25.
//

import Foundation

import Shareds
import UseCase

import ComposableArchitecture
import FirebaseAuth
import LogMacro
import Entity

@Reducer
public struct MemberMain {
  public init() {}

  @ObservableState
  public struct State: Equatable {
    var member: ProfileEntity? = nil

    @ObservationStateIgnored
    var didAppear: Bool = false

    // 출석 현황
    // FIXME: - 기수 활동 기간 수정 필요
    var startDate: String = "2025.05.10"
    var endDate: String = "2025.08.30"
    var presentCount: Int = .zero
    var lateCount: Int = .zero
    var absentCount: Int = .zero
    var showAttendanceWarningIcon: Bool = false
    var isPresentAttendanceWarningAlert: Bool = false

    // 일정표
    var schedules: IdentifiedArrayOf<Schedule> = .init(uniqueElements: [])

    public init() {}
  }

  public enum Action: BindableAction, FeatureAction {
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
  }

  public enum AsyncAction: Equatable {
    case fetchCurrentUser
    case fetchAttendanceCount(userID: Int)
    case fetchSchedule
  }

  public enum InnerAction: Equatable {
    case onFetchUserResponse(Result<ProfileEntity, CustomError>)
    case onFetchAttendanceCountResponse(Result<AttendanceCountResponseModel, CustomError>)
    case onFetchSchedulesResponse(Result<[Schedule], CustomError>)
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

  public var body: some ReducerOf<Self> {
    BindingReducer()

    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case .view(let action):
        return handleViewAction(state: &state, action: action)

      case .inner(let action):
        return handleInnerAction(state: &state, action: action)

      case .async(let action):
        return handleAsyncAction(state: &state, action: action)

      case .navigation(let action):
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
    }
  }

  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {
    case .onFetchUserResponse(let result):
      switch result {
      case .success(let member):
        state.member = member
        #logDebug("Succeed Fetch User Profile", member)
        return .none

      case .failure(let error):
        state.member = nil
        #logError("Failed Fetch User Profile", error)
        return .none
      }

    case .onFetchAttendanceCountResponse(let result):
      switch result {
      case .success(let counts):
        state.presentCount = counts.presentCount
        state.lateCount = counts.lateCount
        state.absentCount = counts.absentCount
        state.showAttendanceWarningIcon = state.absentCount > 0
        #logDebug("Succeed Fetch Attendance Counts", counts)
        return .none

      case .failure(let error):
        #logError("Failed Fetch Count: ", error)
        return .none
      }

    case .onFetchSchedulesResponse(let result):
      switch result {
      case .success(let schedules):
        state.schedules = .init(uniqueElements: schedules)
        #logDebug("Succeed Fetch Schedules: ", schedules)
        return .none

      case .failure(let error):
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
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {
    case .fetchCurrentUser:
      return .run { send in
        let result = await Result {
          try await profileUseCase.getProfile()
        }

//        switch result {
//        case .success(let member):
//          if let member {
////            await send(.inner(.onFetchUserResponse(.success(member))))
////            await send(.async(.fetchAttendanceCount(userID: member.userID)))
//          }
//
//        case .failure(let error):
//          let error = CustomError.map(error)
//          await send(.inner(.onFetchUserResponse(.failure(error))))
//        }
      }

    case .fetchAttendanceCount(let userID):
      return .run { send in
        let result = await Result {
          try await attendanceUseCase.fetchCount(userID: userID)
        }

        switch result {
        case .success(let counts):
          await send(.inner(.onFetchAttendanceCountResponse(.success(counts))))

        case .failure(let error):
          let error = CustomError.map(error)
          await send(.inner(.onFetchAttendanceCountResponse(.failure(error))))
        }
      }

    case .fetchSchedule:
      return .run { send in
        let result = await Result {
          try await attendanceUseCase.getAttendances(startDate: "2025-05-10", endDate: "2025-08-30")
        }

        switch result {
        case .success(let attendances):
          let schedules = attendances?.data.compactMap { $0.toSchedule() } ?? []
          await send(.inner(.onFetchSchedulesResponse(.success(schedules))))

        case .failure(let error):
          let error = CustomError.map(error)
          await send(.inner(.onFetchSchedulesResponse(.failure(error))))
        }
      }
    }
  }

  private func handleNavigationAction(
    state: inout State,
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
