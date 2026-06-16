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
  private let onNext: ([TeamVoteAnswer]) -> Void

  @State private var answers: [CategoryAnswer]

  init(
    info: TeamVoteTemplateInfo,
    initialAnswers: [TeamVoteAnswer] = [],
    onNext: @escaping ([TeamVoteAnswer]) -> Void = { _ in }
  ) {
    let categories = Self.orderedCategories(info.template.categories)
    self.info = info
    self.onNext = onNext
    _answers = State(
      initialValue: Self.makeInitialAnswers(
        categories: categories,
        storedAnswers: initialAnswers
      )
    )
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        StepProgressBar(currentStep: 1, totalSteps: 2)

        TeamVoteHeaderView(
          title: info.template.title,
          description: info.template.description,
          notice: info.template.notice
        )

        ForEach(answers.indices, id: \.self) { index in
          TeamVoteCategoryView(
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

  private static func orderedCategories(_ categories: [TeamVoteCategory]) -> [TeamVoteCategory] {
    categories.enumerated()
      .sorted { lhs, rhs in
        guard lhs.element.order != rhs.element.order else {
          return lhs.offset < rhs.offset
        }
        return lhs.element.order < rhs.element.order
      }
      .map(\.element)
  }

  private static func makeInitialAnswers(
    categories: [TeamVoteCategory],
    storedAnswers: [TeamVoteAnswer]
  ) -> [CategoryAnswer] {
    var answerByCategory: [String: TeamVoteAnswer] = [:]
    for answer in storedAnswers {
      answerByCategory[answer.categoryId] = answer
    }

    return categories.map { category in
      let storedAnswer = answerByCategory[category.id]
      return CategoryAnswer(
        category: category,
        selectedTeamIds: Set(storedAnswer?.teamIds ?? []),
        reason: storedAnswer?.reason ?? ""
      )
    }
  }

  private func makeTeamVoteAnswers() -> [TeamVoteAnswer] {
    answers.map { answer in
      TeamVoteAnswer(
        categoryId: answer.category.id,
        teamIds: Array(answer.selectedTeamIds),
        reason: answer.reason.isEmpty ? nil : answer.reason
      )
    }
  }

  private var nextButton: some View {
    Button {
      onNext(makeTeamVoteAnswers())
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
