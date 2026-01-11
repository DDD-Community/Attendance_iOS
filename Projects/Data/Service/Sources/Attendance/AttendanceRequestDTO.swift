//
//  AttendanceRequestDTO.swift
//  Service
//
//  Created by Wonji Suh  on 1/11/26.
//

import Foundation

public struct AttendanceRequestDTO: Equatable, Encodable {
  public let scheduleId: Int
  public let teamId: Int

  public init(
    scheduleId: Int,
    teamId: Int
  ) {
    self.scheduleId = scheduleId
    self.teamId = teamId
  }
}
