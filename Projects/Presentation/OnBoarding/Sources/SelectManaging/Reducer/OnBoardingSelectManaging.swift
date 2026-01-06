//
//  OnBoardingSelectManaging.swift
//  Presentation
//
//  Created by Wonji Suh  on 11/3/24.
//

import Foundation

import UseCase
import Entity
import Utill

import AsyncMoya
import ComposableArchitecture

@Reducer
public struct SelectManagingReducer {
  public init() {}

  @ObservableState
  public struct State: Equatable {
    public init() {}

    var loading: Bool = false
    var activeButton: Bool = false
    var errorMessage: String?
    var selectMangers: [SelectManaging]? = [ ]
    var signUpUser: SignUpUser?

    @Shared(.inMemory("UserSession")) var userSession: UserSession = .empty


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
    case onAppear
    case selectManagingButton(selectManaging: SelectManaging)
  }

  // MARK: - AsyncAction 비동기 처리 액션

  public enum AsyncAction: Equatable {
    case fetchMangerList
  }

  // MARK: - 앱내에서 사용하는 액션

  public enum InnerAction: Equatable {
    case mangerListResponse(Result<[SelectManaging], SignUpError>)
  }

  // MARK: - NavigationAction

  public enum NavigationAction: Equatable {
    case presentCoreMember
    case presentSelectTeam
  }

  nonisolated enum CancelID: Hashable {
    case fetchMangerList
  }

  @Dependency(\.onBoardingUseCase) var onBoardingUseCase
  @Dependency(\.continuousClock) var clock
  @Dependency(\.mainQueue) var mainQueue

  public var body: some ReducerOf<Self> {
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

extension SelectManagingReducer {
  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
      case .onAppear:
        return .send(.async(.fetchMangerList))

      case .selectManagingButton(let selectManaging):
        let selectedManaging = selectManaging.managing
        var updatedManaging: [StaffManaging] = []

        state.$userSession.withLock {
          var current = $0.managing
          if let index = current.firstIndex(of: selectedManaging) {
            current.remove(at: index)
          } else {
            current.append(selectedManaging)
          }
          $0.managing = current
          updatedManaging = current
        }

        state.activeButton = !updatedManaging.isEmpty
        return .none
    }
  }

  private func handleNavigationAction(
    state: inout State,
    action: NavigationAction
  ) -> Effect<Action> {
    switch action {
      case .presentCoreMember:
        return .none

      case .presentSelectTeam:
        return .none
    }
  }

  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {
      case .fetchMangerList:
        state.loading = true
        return .run { send in
          let mangerResult = await Result {
            try await onBoardingUseCase.fetchManaging()
          }
            .mapError(SignUpError.from)
          return await send(.inner(.mangerListResponse(mangerResult)))
        }
        .cancellable(id: CancelID.fetchMangerList, cancelInFlight: true)

    }
  }

  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {
      case .mangerListResponse(let result):
        switch result {
          case .success(let data):
            state.loading = false
            state.selectMangers = data

          case .failure(let error):
            state.errorMessage =  error.errorDescription

        }
        return .none
    }

  }
}
