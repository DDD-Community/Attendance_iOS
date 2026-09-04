//
//  AttendanceSummaryResponseDTO.swift
//  MyPageDomain
//
//  Created by DDD on 1/12/26.
//

import Foundation

public struct AttendanceSummaryResponseDTO: Decodable, Sendable {
  public let totalAttended: Int
  public let totalLate: Int
  public let totalAbsent: Int
  
  public init(totalAttended: Int, totalLate: Int, totalAbsent: Int) {
    self.totalAttended = totalAttended
    self.totalLate = totalLate
    self.totalAbsent = totalAbsent
  }
}
