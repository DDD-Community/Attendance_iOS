//
//  ScheduleRepositoryProtocol.swift
//  UseCase
//
//  Created by Wonji Suh  on 5/9/25.
//

import Model

public protocol ScheduleRepositoryProtocol {
  func getSchedules()  async throws -> ScheduleModel?
  func filtergetSchedules(startDate: String) async throws -> ScheduleModel?
}
