//
//  VoteFeature.swift
//  Management
//
//  Created by Wonji Suh  on 6/11/26.
//

import ComposableArchitecture
import DesignSystem
import Entity
import Foundation
import LogMacro

@Reducer
public struct VoteFeature {
  public init() {}

  @ObservableState
  public struct State: Equatable {
    var loading: Bool = false
    var voteStatus: VoteStatus = .before
    var isNonParticipantsPresented: Bool = false
    var nonParticipants: [NonParticipant] = []
    @Presents public var customAlert: CustomAlertState<CustomAlertAction>?
    public init() {}
  }

  public enum Action: ViewAction, BindableAction {
    case binding(BindingAction<State>)
    case view(View)
    case async(AsyncAction)
    case inner(InnerAction)
    case delegate(DelegateAction)
    case scope(ScopeAction)
  }

  // MARK: - ViewAction

  @CasePathable
  public enum View {
    case tappedStartVoteButton
    case tappedCheckNonParticipants
    case tappedCloseNonParticipants
    case tappedEndVoteButton
  }

  // MARK: - ScopeAction

  @CasePathable
  public enum ScopeAction {
    case customAlert(PresentationAction<CustomAlertAction>)
  }

  // MARK: - AsyncAction 비동기 처리 액션

  public enum AsyncAction: Equatable {}

  // MARK: - 앱내에서 사용하는 액션

  public enum InnerAction: Equatable {}

  // MARK: - NavigationAction

  public enum DelegateAction: Equatable {}

  nonisolated enum CancelID: Hashable {}

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

      case let .delegate(delegateAction):
        return handleDelegateAction(state: &state, action: delegateAction)

      case let .scope(scopeAction):
        switch scopeAction {
        case let .customAlert(customAlertAction):
          return handleCustomAlertAction(state: &state, action: customAlertAction)
        }
      }
    }
    .ifLet(\.$customAlert, action: \.scope.customAlert) {
      CustomConfirmAlert()
    }
  }
}

extension VoteFeature {
  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
    case .tappedStartVoteButton:
      state.customAlert = .startVote()
      return .none

    case .tappedCheckNonParticipants:
      // TODO: API 연동 후 GET /votes/{id}/non-responders 결과로 대체
      state.nonParticipants = NonParticipant.placeholders
      state.isNonParticipantsPresented = true
      return .none

    case .tappedCloseNonParticipants:
      state.isNonParticipantsPresented = false
      return .none

    case .tappedEndVoteButton:
      state.customAlert = .endVote()
      return .none
    }
  }

  private func handleCustomAlertAction(
    state: inout State,
    action: PresentationAction<CustomAlertAction>
  ) -> Effect<Action> {
    switch action {
    case let .presented(customAlertAction):
      let alertStyle = state.customAlert?.style

      switch customAlertAction {
      // 좌측 회색 버튼("취소") = 닫기
      case .confirmTapped:
        state.customAlert = nil
        return .none

      // 우측 accent 버튼 = 실행 (시작하기 / 종료하기)
      case .cancelTapped:
        state.customAlert = nil
        // TODO: API 연동 후 성공 응답 시 상태 전환
        switch alertStyle {
        case .startConfirmation:
          state.voteStatus = .inProgress
        case .endConfirmation:
          state.voteStatus = .after
        default:
          break
        }
        return .none

      case .policyTapped:
        return .none
      }

    case .dismiss:
      return .none
    }
  }

  private func handleAsyncAction(
    state _: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {}
  }

  private func handleInnerAction(
    state _: inout State,
    action _: InnerAction
  ) -> Effect<Action> {}

  private func handleDelegateAction(
    state _: inout State,
    action: DelegateAction
  ) -> Effect<Action> {
    switch action {}
  }
}
