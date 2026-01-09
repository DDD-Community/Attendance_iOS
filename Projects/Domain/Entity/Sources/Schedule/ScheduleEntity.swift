//
//  Schedule.swift
//  Entity
//
//  Created by Wonji Suh  on 1/10/26.
//

import Foundation

public struct ScheduleEntity: Equatable {
  public let id: Int
  public let name: String
  public let description: String
  public let month, day: Int

  public init(
    id: Int,
    name: String,
    description: String,
    month: Int,
    day: Int
  ) {
    self.id = id
    self.name = name
    self.description = description
    self.month = month
    self.day = day
  }

}
