//
//  TeamVoteQuestionHeaderView.swift
//  Member
//
//  Created by DDD on 6/16/26.
//

import SwiftUI

import DDDDesignKit

/// 팀 투표 부문 헤더. 질문 제목 + 최대 선택 수 + 현재 선택 수로 구성된다.
struct TeamVoteQuestionHeaderView: View {
  private let title: String
  private let maxSelectableTeams: Int
  private let selectedCount: Int

  init(
    title: String,
    maxSelectableTeams: Int,
    selectedCount: Int
  ) {
    self.title = title
    self.maxSelectableTeams = maxSelectableTeams
    self.selectedCount = selectedCount
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .pretendardFont(family: .Bold, size: 20)
        .foregroundStyle(.staticWhite)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)

      HStack {
        Text("각 부문 최대 \(maxSelectableTeams)팀 선택")
          .pretendardFont(family: .Regular, size: 14)
          .foregroundStyle(.borderInactive)

        Spacer()

        Text("\(selectedCount) / \(maxSelectableTeams)")
          .pretendardFont(family: .Medium, size: 14)
          .foregroundStyle(selectedCount == 0 ? Color.gray60 : Color.blue40)
      }
    }
  }
}
