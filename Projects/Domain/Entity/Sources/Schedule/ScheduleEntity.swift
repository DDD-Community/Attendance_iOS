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
  public let month, day, year: Int

  public init(
    id: Int,
    name: String,
    description: String,
    month: Int,
    day: Int,
    year: Int
  ) {
    self.id = id
    self.name = name
    self.description = description
    self.month = month
    self.day = day
    self.year = year
  }
}

public extension ScheduleEntity {
   func toDate(timeZone: TimeZone = .init(identifier: "Asia/Seoul")!) -> Date? {
      var cal = Calendar(identifier: .gregorian)
      cal.timeZone = timeZone

      var comps = DateComponents()
      comps.year = year
      comps.month = month
      comps.day = day
      comps.hour = 0
      comps.minute = 0
      comps.second = 0

      return cal.date(from: comps)
    }
  }
