//
//  FeedbackChipGroup.swift
//  DDDDesignKit
//
//  Created by Roy on 6/10/26.
//

import SwiftUI

/// 서버에서 내려온 칩 목록을 받아 자동 줄바꿈으로 배치하는 다중 선택 그룹.
/// `items`만 갈아끼우면 칩 개수/내용이 그대로 반영된다.
public struct FeedbackChipGroup: View {
  private let items: [ChipItem]
  @Binding private var selectedIDs: Set<String>
  private let horizontalSpacing: CGFloat
  private let verticalSpacing: CGFloat

  public init(
    items: [ChipItem],
    selectedIDs: Binding<Set<String>>,
    horizontalSpacing: CGFloat = 8,
    verticalSpacing: CGFloat = 8
  ) {
    self.items = items
    _selectedIDs = selectedIDs
    self.horizontalSpacing = horizontalSpacing
    self.verticalSpacing = verticalSpacing
  }

  public var body: some View {
    FlowLayout(
      horizontalSpacing: horizontalSpacing,
      verticalSpacing: verticalSpacing
    ) {
      ForEach(items) { item in
        FeedbackChip(
          title: item.title,
          isSelected: selectedIDs.contains(item.id)
        ) {
          toggle(item.id)
        }
      }
    }
  }

  private func toggle(_ id: String) {
    if selectedIDs.contains(id) {
      selectedIDs.remove(id)
    } else {
      selectedIDs.insert(id)
    }
  }
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
