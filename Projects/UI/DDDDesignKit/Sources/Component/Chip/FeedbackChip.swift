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
  private var title: String
  private var isSelected: Bool
  private var action: () -> Void

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

// MARK: - 체이닝 설정
//
// 값 타입 사본을 돌려주므로 호출 순서에 영향받지 않는다.
// 기존 init 은 그대로 두어, 체이닝은 선택지로만 더한다.
public extension FeedbackChip {
  /// `title` 을 바꾼 사본을 돌려준다.
  func title(_ title: String) -> Self {
    var copy = self
    copy.title = title
    return copy
  }
  /// `isSelected` 을 바꾼 사본을 돌려준다.
  func isSelected(_ isSelected: Bool) -> Self {
    var copy = self
    copy.isSelected = isSelected
    return copy
  }
  /// `action` 을 바꾼 사본을 돌려준다.
  func action(_ action: @escaping () -> Void) -> Self {
    var copy = self
    copy.action = action
    return copy
  }
}
