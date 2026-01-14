//
//  AttendancesSummary.swift
//  Entity
//
//  Created by 홍은표 on 1/12/26.
//

import Foundation

public struct AttendanceSummaryResponse: Equatable {
  public let totalAttended: Int
  public let totalLate: Int
  public let totalAbsent: Int
  
  public init(
    totalAttended: Int,
    totalLate: Int,
    totalAbsent: Int
  ) {
    self.totalAttended = totalAttended
    self.totalLate = totalLate
    self.totalAbsent = totalAbsent
  }
}
