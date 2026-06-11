//
//  VoteView.swift
//  Management
//
//  Created by Wonji Suh  on 6/11/26.
//

import SwiftUI

import DesignSystem
import Entity

import ComposableArchitecture

public struct VoteView: View {
  @Bindable var store: StoreOf<VoteFeature>

  public init(store: StoreOf<VoteFeature>) {
    self.store = store
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: 20) {
      voteHeaderView()

      voteStatusView()

      switch store.voteStatus {
      case .before:
        startVoteButton()
      case .inProgress:
        checkNonParticipantsButton()
        endVoteButton()
      case .after:
        checkNonParticipantsButton()
        endedNoticeView()
      }

      Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .padding(.top, 20)
    .padding(.horizontal, 24)
    .customAlert($store.scope(state: \.customAlert, action: \.scope.customAlert))
    .overlay {
      if store.isNonParticipantsPresented {
        NonParticipantsModalView(
          members: store.nonParticipants,
          onClose: {
            store.send(.view(.tappedCloseNonParticipants))
          }
        )
        .transition(.opacity)
      }
    }
    .animation(.easeInOut(duration: 0.2), value: store.isNonParticipantsPresented)
  }
}

extension VoteView {
  @ViewBuilder
  func voteHeaderView() -> some View {
    VStack(alignment: .leading, spacing: 6) {
      HStack {
        Text("투표 관리")
          .pretendardCustomFont(textStyle: .tilte1NormalBold)
          .foregroundStyle(.staticWhite)

        Spacer()
      }

      Text("운영진 전용 화면이에요. 투표 진행을 관리할 수 있어요.")
        .pretendardCustomFont(textStyle: .body3NormalMedium)
        .foregroundStyle(.textCaption)
    }
  }

  /// ① 투표 상태 + ② 참여 현황 — 단일 카드 안에 2개 행 + 구분선
  @ViewBuilder
  func voteStatusView() -> some View {
    VStack(spacing: 0) {
      // ① 투표 상태 — 상태 칩
      HStack(spacing: 0) {
        Text("투표 상태")
          .pretendardCustomFont(textStyle: .body3NormalMedium)
          .foregroundStyle(.textCaption)

        Spacer()

        statusChip()
      }
      .padding(.vertical, 14)

      // 구분선
      Rectangle()
        .fill(.gray80)
        .frame(height: 1)

      // ② 참여 현황
      HStack(spacing: 0) {
        Text("참여 현황")
          .pretendardCustomFont(textStyle: .body3NormalMedium)
          .foregroundStyle(.textCaption)

        Spacer()

        Text(participationText)
          .pretendardCustomFont(textStyle: .body3NormalMedium)
          .foregroundStyle(store.voteStatus == .before ? Color.textCaption : Color.staticWhite)
          .multilineTextAlignment(.trailing)
      }
      .padding(.vertical, 14)
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 4)
    .frame(maxWidth: .infinity)
    .background {
      RoundedRectangle(cornerRadius: 12)
        .fill(.gray90)
    }
  }

  /// 투표 상태 칩 — 투표 전(회색) / 진행 중(파랑) / 투표 종료(회색)
  @ViewBuilder
  func statusChip() -> some View {
    Text(statusChipTitle)
      .pretendardFont(family: .Bold, size: 12)
      .foregroundStyle(statusChipForeground)
      .padding(.horizontal, 10)
      .padding(.vertical, 4)
      .background {
        RoundedRectangle(cornerRadius: 6)
          .fill(statusChipBackground)
      }
  }

  var statusChipTitle: String {
    switch store.voteStatus {
    case .before: return "투표 전"
    case .inProgress: return "진행 중"
    case .after: return "투표 종료"
    }
  }

  var statusChipForeground: Color {
    switch store.voteStatus {
    case .before: return .borderInactive
    case .inProgress: return .staticWhite
    case .after: return .textCaption
    }
  }

  var statusChipBackground: Color {
    switch store.voteStatus {
    case .before, .after: return .gray80
    case .inProgress: return .blue40
    }
  }

  /// 참여 현황 텍스트
  var participationText: String {
    switch store.voteStatus {
    case .before:
      return "투표 시작 전이에요"
    case .inProgress:
      // TODO: API 연동 후 실제 참여 현황으로 대체
      return "42명 중 35명 참여 (83%)"
    case .after:
      // TODO: API 연동 후 실제 최종 집계로 대체
      return "최종 38명 참여 (90%)"
    }
  }

  /// 투표 전 — '투표 시작하기' CTA (파랑)
  @ViewBuilder
  func startVoteButton() -> some View {
    CustomButton(
      action: {
        store.send(.view(.tappedStartVoteButton))
      },
      title: "투표 시작하기",
      config: CustomButtonConfig.createVoteButton(),
      isEnable: true
    )
  }

  /// 진행 중 — '미참여 인원 확인하기' (아웃라인)
  @ViewBuilder
  func checkNonParticipantsButton() -> some View {
    Button {
      store.send(.view(.tappedCheckNonParticipants))
    } label: {
      HStack(spacing: 8) {
        Text("미참여 인원 확인하기")
          .pretendardFont(family: .Bold, size: 15)
          .foregroundStyle(.staticWhite)

        Image(systemName: "arrow.right")
          .font(.system(size: 14, weight: .bold))
          .foregroundStyle(.staticWhite)
      }
      .frame(maxWidth: .infinity)
      .frame(height: 52)
      .overlay {
        RoundedRectangle(cornerRadius: 10)
          .strokeBorder(Color.borderNormal, lineWidth: 1)
      }
    }
    .buttonStyle(.plain)
  }

  /// 진행 중 — '투표 종료하기' CTA (빨강)
  @ViewBuilder
  func endVoteButton() -> some View {
    CustomButton(
      action: {
        store.send(.view(.tappedEndVoteButton))
      },
      title: "투표 종료하기",
      config: CustomButtonConfig.createEndVoteButton(),
      isEnable: true
    )
  }

  /// 투표 종료 — '투표가 종료되었어요' 비활성 안내 (회색, 탭 불가)
  @ViewBuilder
  func endedNoticeView() -> some View {
    Text("투표가 종료되었어요")
      .pretendardFont(family: .Bold, size: 16)
      .foregroundStyle(.textCaption)
      .frame(maxWidth: .infinity)
      .frame(height: 52)
      .background {
        RoundedRectangle(cornerRadius: 10)
          .fill(Color.gray80)
      }
  }
}

#Preview {
  VoteView(store: .init(initialState: VoteFeature.State(), reducer: {
    VoteFeature()
  }))
  .background(Color.backGroundPrimary)
}
