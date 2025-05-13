//
//  DefaultScheduleRepository.swift
//  UseCase
//
//  Created by Wonji Suh  on 5/9/25.
//

import Model

final public class DefaultScheduleRepository: ScheduleRepositoryProtocol  {
  
  public init() {}
  
  public func getSchedules() async throws -> ScheduleDTOModel? {
    return nil
  }
}
