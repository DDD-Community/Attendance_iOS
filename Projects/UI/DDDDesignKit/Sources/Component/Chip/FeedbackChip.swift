//
//  FeedbackChip.swift
//  DDDDesignKit
//
//  Created by DDD on 6/10/26.
//

import SwiftUI

/// 참여 경험 피드백 화면의 단일 칩.
/// 선택 시 파란 채움(statusFocus) + 흰 텍스트, 미선택 시 외곽선 + 회색 텍스트.
public struct FeedbackChip: View {
  private let title: String
  private let isSelected: Bool
  private let action: () -> Void

  public init(
    title: String,
    isSelected: Bool,
    action: @escaping () -> Void
  ) {
    self.title = title
    self.isSelected = isSelected
    self.action = action
  }

  public var body: some View {
    Button {
      action()
    } label: {
      Text(title)
        .pretendardFont(family: .Medium, size: 14)
        .foregroundStyle(isSelected ? Color.staticWhite : Color.borderInactive)
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background {
          Capsule()
            .fill(isSelected ? Color.statusFocus : Color.clear)
            .overlay {
              Capsule()
                .strokeBorder(.borderNormal, lineWidth: isSelected ? 0 : 1)
            }
        }
    }
    .buttonStyle(.plain)
  }
}

#Preview {
  HStack(spacing: 8) {
    FeedbackChip(title: "OT", isSelected: true, action: {})
    FeedbackChip(title: "부스팅 데이", isSelected: false, action: {})
  }
  .padding()
  .background(Color.backGroundPrimary)
}

#Preview {
  struct PreviewContainer: View {
    private let items = [
      "OT", "부스팅 데이", "직군세션1",
      "UT 1차", "중간 발표", "티키타카",
      "UT 2차", "직군세션 2", "최종 발표"
    ].map { ChipItem(id: $0, title: $0) }

    @State private var selected: Set<String> = ["OT", "중간 발표", "최종 발표"]

    var body: some View {
      FeedbackChipGroup(items: items, selectedIDs: $selected)
        .padding(24)
        .frame(maxWidth: 375, alignment: .leading)
        .background(Color.backGroundPrimary)
    }
  }
  return PreviewContainer()
}
