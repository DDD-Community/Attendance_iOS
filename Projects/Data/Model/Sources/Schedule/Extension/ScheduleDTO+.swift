//
//  ScheduleDTO+.swift
//  Model
//
//  Created by Wonji Suh  on 1/10/26.
//

import Foundation
import Entity


public extension ScheduleDTOResponse {
  func toDomain() -> ScheduleEntity {
    return ScheduleEntity(
      id: self.id,
      name: self.name,
      description: self.desc,
      month: self.month,
      day: self.day,
      year: self.year
    )
  }
}


public extension Array where Element == ScheduleDTOResponse {
  func toDomain() -> [ScheduleEntity] {
    return self.map { $0.toDomain() }
  }
}

public extension ScheduleDTO {
  func toDomain() -> [ScheduleEntity] {
    return self.data.toDomain()
  }
}
