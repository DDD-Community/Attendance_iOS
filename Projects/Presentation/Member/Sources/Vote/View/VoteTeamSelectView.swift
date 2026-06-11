//
//  VoteTeamSelectView.swift
//  Member
//
//  Created by Roy on 6/11/26.
//

import SwiftUI

import DesignSystem
import Entity

/// [멤버] 투표 1단계 — 팀 선택 화면 (Figma: iOS/투표_1단계(팀 선택))
struct VoteTeamSelectView: View {
  private struct CategoryAnswer: Identifiable {
    let category: TeamVoteCategory
    var selectedTeamIds: Set<Int> = []
    var reason: String = ""
    var id: String { category.id }
  }

  private let info: TeamVoteTemplateInfo
  private let onNext: () -> Void

  @State private var answers: [CategoryAnswer]

  init(
    info: TeamVoteTemplateInfo,
    onNext: @escaping () -> Void = {}
  ) {
    self.info = info
    self.onNext = onNext
    _answers = State(initialValue: info.template.categories.map { CategoryAnswer(category: $0) })
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        StepProgressBar(currentStep: 1, totalSteps: 2)

        headerView

        ForEach(answers.indices, id: \.self) { index in
          TeamVoteCategoryView(
            index: index,
            category: answers[index].category,
            teams: info.teams,
            selectedTeamIds: $answers[index].selectedTeamIds,
            reason: $answers[index].reason
          )
        }

        nextButton
      }
      .padding(.horizontal, 24)
      .padding(.top, 20)
      .padding(.bottom, 24)
    }
    .scrollIndicators(.hidden)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.backGroundPrimary)
  }

  private var headerView: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(info.template.title)
        .pretendardFont(family: .Bold, size: 28)
        .foregroundStyle(.staticWhite)

      Text(info.template.description)
        .pretendardFont(family: .Regular, size: 16)
        .foregroundStyle(.borderInactive)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)

      if !info.template.notice.isEmpty {
        Text(info.template.notice)
          .pretendardFont(family: .Regular, size: 14)
          .foregroundStyle(.gray60)
          .fixedSize(horizontal: false, vertical: true)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
  }

  private var nextButton: some View {
    Button {
      onNext()
    } label: {
      Text("다음")
        .pretendardFont(family: .Bold, size: 16)
        .foregroundStyle(.staticWhite)
        .frame(maxWidth: .infinity)
        .frame(height: 55)
        .background {
          RoundedRectangle(cornerRadius: 14)
            .fill(Color.blue40)
        }
    }
    .buttonStyle(.plain)
  }
}
