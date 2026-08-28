//
//  AttendanceSummaryResponseDTO+.swift
//  Repository
//
//  Created by DDD on 1/12/26.
//

import Foundation

import Entity

public extension AttendanceSummaryResponseDTO {
  func toDomain() -> AttendanceSummaryResponse {
    return .init(
      totalAttended: totalAttended,
      totalLate: totalLate,
      totalAbsent: totalAbsent
    )
  }
}
