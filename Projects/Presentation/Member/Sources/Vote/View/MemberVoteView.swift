//
//  MemberVoteView.swift
//  Member
//
//  Created by Roy on 6/11/26.
//

import SwiftUI

import DesignSystem
import Entity

import ComposableArchitecture

/// [멤버] 투표 탭 컨테이너. 단계(Step)에 따라 팀 선택/피드백/완료 화면을 전환한다.
@ViewAction(for: MemberVote.self)
struct MemberVoteView: View {
  @Bindable var store: StoreOf<MemberVote>

  init(store: StoreOf<MemberVote>) {
    self.store = store
  }

  var body: some View {
    content()
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color.backGroundPrimary)
      .alert($store.scope(state: \.alert, action: \.scope.alert))
      .onAppear {
        send(.onAppear)
      }
  }

  @ViewBuilder
  private func content() -> some View {
    switch store.step {
    case .loading:
      loadingView()

    case .empty:
      messageView(
        title: "진행 중인 투표가 없어요",
        description: "새로운 투표가 열리면 이곳에서 참여할 수 있어요."
      )

    case .alreadyVoted:
      messageView(
        title: "이미 투표에 참여했어요",
        description: "투표 결과는 집계 후 공개될 예정이에요."
      )

    case .teamSelect:
      if let info = store.teamTemplate {
        VoteTeamSelectView(
          info: info,
          initialAnswers: store.teamAnswers,
          onNext: { answers in
            send(.teamSelectNext(answers))
          }
        )
      } else {
        loadingView()
      }

    case .feedback:
      if let info = store.feedbackTemplate {
        VoteFeedbackView(info: info) { answers in
          send(.submitFeedback(answers))
        }
      } else {
        loadingView()
      }

    case .completed:
      messageView(
        title: "투표를 완료했어요",
        description: "소중한 의견 감사합니다."
      )
    }
  }

  @ViewBuilder
  private func loadingView() -> some View {
    ProgressView()
      .progressViewStyle(.circular)
      .tint(.staticWhite)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  @ViewBuilder
  private func messageView(
    title: String,
    description: String
  ) -> some View {
    VStack(spacing: 8) {
      Text(title)
        .pretendardFont(family: .Bold, size: 18)
        .foregroundStyle(.staticWhite)

      Text(description)
        .pretendardFont(family: .Medium, size: 14)
        .foregroundStyle(.textCaption)
        .multilineTextAlignment(.center)
    }
    .padding(.horizontal, 24)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
