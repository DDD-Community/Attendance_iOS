//
//  ScheduleCacheModel.swift
//  ScheduleDomain
//
//  Created by DDD on 5/12/26.
//

import Foundation
import SwiftData


@Model
final class ScheduleCacheEntity {
  @Attribute(.unique) var id: Int
  var cachedAt: Date
  var name: String
  var scheduleDescription: String
  var month: Int
  var day: Int
  var year: Int

  init(
    id: Int,
    cachedAt: Date,
    name: String,
    scheduleDescription: String,
    month: Int,
    day: Int,
    year: Int
  ) {
    self.id = id
    self.cachedAt = cachedAt
    self.name = name
    self.scheduleDescription = scheduleDescription
    self.month = month
    self.day = day
    self.year = year
  }

  // 만료: 당일
  var isExpired: Bool {
    !Calendar.current.isDate(cachedAt, inSameDayAs: Date())
  }

  func toDomain() -> Schedule {
    Schedule(
      id: id,
      name: name,
      description: scheduleDescription,
      month: month,
      day: day,
      year: year
    )
  }
}

extension Schedule {
  func toCacheModel(cachedAt: Date = Date()) -> ScheduleCacheEntity {
    ScheduleCacheEntity(
      id: id,
      cachedAt: cachedAt,
      name: name,
      scheduleDescription: description,
      month: month,
      day: day,
      year: year
    )
  }
}
