//
//  HomeDropdownMenu.swift
//  DesignSystem
//
//  Created by Roy on 6/11/26.
//

import SwiftUI

/// 홈 상단 드롭다운 메뉴 (Figma: iOS/홈_드롭다운).
/// 도메인 비의존 — feature 에서 항목을 매핑해 사용한다.
public struct HomeDropdownMenu: View {
  public struct Entry: Identifiable {
    public let id: String
    public let title: String
    public let isSelected: Bool
    public let showsNewBadge: Bool

    public init(
      id: String,
      title: String,
      isSelected: Bool,
      showsNewBadge: Bool = false
    ) {
      self.id = id
      self.title = title
      self.isSelected = isSelected
      self.showsNewBadge = showsNewBadge
    }
  }

  private let entries: [Entry]
  private let onSelect: (Entry) -> Void

  public init(
    entries: [Entry],
    onSelect: @escaping (Entry) -> Void
  ) {
    self.entries = entries
    self.onSelect = onSelect
  }

  public var body: some View {
    VStack(spacing: 0) {
      ForEach(entries) { entry in
        menuItem(entry)
      }
    }
    .padding(.vertical, 8)
    .frame(width: 224)
    .background {
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.gray90)
        .overlay {
          RoundedRectangle(cornerRadius: 16)
            .strokeBorder(Color.borderDisabled, lineWidth: 1)
        }
    }
  }

  private func menuItem(_ entry: Entry) -> some View {
    HStack(spacing: 8) {
      Text(entry.title)
        .pretendardFont(family: entry.isSelected ? .Bold : .Medium, size: 16)
        .foregroundStyle(entry.isSelected ? Color.staticWhite : Color.borderInactive)

      if entry.showsNewBadge {
        newBadge
      }

      Spacer(minLength: 0)
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 14)
    .frame(maxWidth: .infinity, alignment: .leading)
    .contentShape(Rectangle())
    .onTapGesture { onSelect(entry) }
  }

  private var newBadge: some View {
    Text("NEW")
      .pretendardFont(family: .Bold, size: 10)
      .foregroundStyle(.staticWhite)
      .padding(.horizontal, 8)
      .padding(.vertical, 3)
      .background {
        Capsule().fill(Color.blue40)
      }
  }
}
