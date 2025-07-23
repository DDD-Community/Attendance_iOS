//
//  DefaultScheduleRepositoryImpl.swift
//  Repository
//
//  Created by Wonji Suh  on 7/23/25.
//

import DomainInterface
import Model

final public class DefaultScheduleRepositoryImpl: ScheduleInterface  {

  public init() {}

  public func getSchedules() async throws -> ScheduleModel? {
    return nil
  }

  public func filtergetSchedules(
    startDate: String
  ) async throws -> ScheduleModel? {
    return nil
  }
}

