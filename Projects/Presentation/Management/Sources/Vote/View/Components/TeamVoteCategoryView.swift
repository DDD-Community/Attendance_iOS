//
//  TeamVoteCategoryView.swift
//  Management
//
//  Created by Roy on 6/11/26.
//

import SwiftUI

import DesignSystem
import Entity

/// 팀 투표 1단계의 부문(질문) 한 개 블록.
/// 질문 + 선택 카운트 + 팀 리스트 + 이유 입력으로 구성된다.
struct TeamVoteCategoryView: View {
  let index: Int
  let category: TeamVoteCategory
  let teams: [VoteTeam]
  @Binding var selectedTeamIds: Set<Int>
  @Binding var reason: String

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      questionHeader
      teamList
      reasonEditor
    }
  }

  private var questionHeader: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("\(index + 1). \(category.title)")
        .pretendardFont(family: .Bold, size: 20)
        .foregroundStyle(.staticWhite)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)

      HStack {
        Text("각 부문 최대 \(category.maxSelectableTeams)팀 선택")
          .pretendardFont(family: .Regular, size: 14)
          .foregroundStyle(.borderInactive)

        Spacer()

        Text("\(selectedTeamIds.count) / \(category.maxSelectableTeams)")
          .pretendardFont(family: .Medium, size: 14)
          .foregroundStyle(selectedTeamIds.isEmpty ? Color.gray60 : Color.blue40)
      }
    }
  }

  private var teamList: some View {
    VStack(spacing: 0) {
      ForEach(Array(teams.enumerated()), id: \.element.id) { idx, team in
        TeamSelectionRow(
          team: team,
          isSelected: selectedTeamIds.contains(team.id),
          onTap: { toggle(team) }
        )

        if idx < teams.count - 1 {
          Rectangle()
            .fill(Color.gray90)
            .frame(height: 1)
        }
      }
    }
  }

  private var reasonEditor: some View {
    FeedbackTextEditor(
      description: "좋았던 이유를 작성해주세요.",
      placeholder: "해당 팀을 선택하신 이유를 적어주세요. 실현 가능성, 사용자 편의성, 독창성 등을 종합적으로 고려하여 작성해 주세요.",
      text: $reason,
      minLength: category.reasonMinLength,
      maxLength: category.reasonMaxLength
    )
  }

  private func toggle(_ team: VoteTeam) {
    if selectedTeamIds.contains(team.id) {
      selectedTeamIds.remove(team.id)
    } else if selectedTeamIds.count < category.maxSelectableTeams {
      selectedTeamIds.insert(team.id)
    }
  }
}
