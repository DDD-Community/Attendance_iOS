//
//  TeamVoteHeaderView.swift
//  Member
//
//  Created by DDD on 6/16/26.
//

import SwiftUI

import DDDDesignKit

/// 팀 투표 화면 상단 헤더. 제목 + 설명 + 안내 문구로 구성된다.
struct TeamVoteHeaderView: View {
  private let title: String
  private let description: String
  private let notice: String

  init(
    title: String,
    description: String,
    notice: String
  ) {
    self.title = title
    self.description = description
    self.notice = notice
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .pretendardFont(family: .Bold, size: 28)
        .foregroundStyle(.staticWhite)

      Text(description)
        .pretendardFont(family: .Regular, size: 16)
        .foregroundStyle(.borderInactive)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)

      if !notice.isEmpty {
        Text(notice)
          .pretendardFont(family: .Regular, size: 14)
          .foregroundStyle(.gray60)
          .fixedSize(horizontal: false, vertical: true)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
  }
}
