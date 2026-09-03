//
//  AttendanceSummaryResponseDTO+.swift
//  MyPageDomain
//
//  Created by DDD on 1/12/26.
//

import Foundation

import MyPageDomainInterface

public extension AttendanceSummaryResponseDTO {
  func toDomain() -> AttendanceSummaryResponse {
    return .init(
      totalAttended: totalAttended,
      totalLate: totalLate,
      totalAbsent: totalAbsent
    )
  }
}
