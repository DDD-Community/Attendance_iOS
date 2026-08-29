//
//  SelectManaging.swift
//  Entity
//
//  Created by DDD on 1/1/26.
//

import Foundation

public struct SelectManaging: Equatable , Identifiable {
  public let id : String
  public let managingKeys: String
  public let managing: StaffManaging

  public init(
    managingKeys: String,
    managing: StaffManaging
  ) {
    self.id = managingKeys
    self.managingKeys = managingKeys
    self.managing = managing
  }
}
