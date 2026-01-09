//
//  DefaultScheduleRepositoryImpl.swift
//  Repository
//
//  Created by Wonji Suh  on 7/23/25.
//

import Model
import Entity

final public class DefaultScheduleRepositoryImpl: ScheduleInterface  {

  public init() {}

  public func getSchedule() async throws -> [ScheduleEntity] {
    return [
      ScheduleEntity(
        id: 1,
        name: "팀 회의",
        description: "주간 팀 회의 및 프로젝트 진행상황 공유",
        month: 1,
        day: 15
      ),
    ]
  }

}

