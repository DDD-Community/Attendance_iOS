//
//  VoteTeamSelectView.swift
//  Management
//
//  Created by Roy on 6/11/26.
//

import SwiftUI

import DesignSystem
import Entity

/// [멤버] 투표 1단계 — 팀 선택 화면 (Figma: iOS/투표_1단계(팀 선택))
struct VoteTeamSelectView: View {
  let info: TeamVoteTemplateInfo
  var onNext: ([String: Set<Int>], [String: String]) -> Void = { _, _ in }

  @State private var selections: [String: Set<Int>] = [:]
  @State private var reasons: [String: String] = [:]

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        StepProgressBar(currentStep: 1, totalSteps: 2)

        headerView

        ForEach(Array(info.template.categories.enumerated()), id: \.element.id) { index, category in
          TeamVoteCategoryView(
            index: index,
            category: category,
            teams: info.teams,
            selectedTeamIds: binding(for: category.id),
            reason: reasonBinding(for: category.id)
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
      onNext(selections, reasons)
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

  private func binding(for categoryId: String) -> Binding<Set<Int>> {
    Binding(
      get: { selections[categoryId] ?? [] },
      set: { selections[categoryId] = $0 }
    )
  }

  private func reasonBinding(for categoryId: String) -> Binding<String> {
    Binding(
      get: { reasons[categoryId] ?? "" },
      set: { reasons[categoryId] = $0 }
    )
  }
}
