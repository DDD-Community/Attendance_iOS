//
//  DefaultScheduleRepository.swift
//  UseCase
//
//  Created by Wonji Suh  on 5/9/25.
//

import Model

final public class DefaultScheduleRepository: ScheduleRepositoryProtocol  {
  
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
