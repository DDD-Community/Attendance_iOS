//
//  HomeDropdownMenu.swift
//  DDDDesignKit
//
//  Created by Roy on 6/11/26.
//

import SwiftUI

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
        .pretendardFont(family: entry.isSelected ? .Bold : .Medium, size: 20)
        .foregroundStyle(entry.isSelected ? .staticWhite : .borderInactive)

      Spacer(minLength: 0)

      if entry.showsNewBadge {
        newBadge
      }
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
        Capsule().fill(.blue40)
      }
  }
}
