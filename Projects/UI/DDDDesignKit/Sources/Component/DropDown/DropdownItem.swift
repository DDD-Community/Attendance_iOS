//
//  DropdownItem.swift
//  DDDDesignKit
//
//  Created by DDD on 7/13/24.
//

import Foundation

public struct DropdownItem: Identifiable {
  public let id: Int
  public let title: String
  public let onSelect: () -> Void
  
  public init(
    id: Int,
    title: String,
    onSelect: @escaping () -> Void
  ) {
    self.id = id
    self.title = title
    self.onSelect = onSelect
  }
}
