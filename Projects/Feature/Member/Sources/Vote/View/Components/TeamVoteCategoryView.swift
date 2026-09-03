//
//  TeamVoteCategoryView.swift
//  Member
//
//  Created by DDD on 6/11/26.
//

import SwiftUI

import DDDDesignKit
import VoteDomainInterface

/// 팀 투표 1단계의 부문(질문) 한 개 블록.
/// 질문 + 선택 카운트 + 팀 리스트 + 이유 입력으로 구성된다.
struct TeamVoteCategoryView: View {
  let category: TeamVoteCategory
  let teams: [VoteTeam]
  @Binding var selectedTeamIds: Set<Int>
  @Binding var reason: String

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      TeamVoteQuestionHeaderView(
        title: category.title,
        maxSelectableTeams: category.maxSelectableTeams,
        selectedCount: selectedTeamIds.count
      )
      teamList
      reasonEditor
    }
  }

  private var teamList: some View {
    VStack(spacing: 0) {
      ForEach(Array(teams.enumerated()), id: \.element.id) { idx, team in
        TeamSelectionRow(
          name: team.name,
          serviceName: team.serviceName,
          isOwnTeam: team.isOwnTeam,
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
      placeholder: "해당 팀을 선택하신 이유를 적어주세요. 실현 가능성, 사용자 편의성, 독창성 등을 종합적으로 고려하여 작성해 주세요.",
      text: $reason
    )
    .description(reasonDescription)
    .minLength(category.reasonRequired ? category.reasonMinLength : 0)
    .maxLength(category.reasonMaxLength)
  }

  private var reasonDescription: String {
    category.reasonLabel.isEmpty ? "좋았던 이유를 작성해주세요." : category.reasonLabel
  }

  private func toggle(_ team: VoteTeam) {
    if selectedTeamIds.contains(team.id) {
      selectedTeamIds.remove(team.id)
    } else if selectedTeamIds.count < category.maxSelectableTeams {
      selectedTeamIds.insert(team.id)
    }
  }
}
