//
//  ScheduleInterface.swift
//  DomainInterface
//
//  Created by Wonji Suh  on 7/23/25.
//

import Foundation

public protocol ScheduleInterface {
  func getSchedules()  async throws -> ScheduleModel?
  func filtergetSchedules(startDate: String) async throws -> ScheduleModel?
}
