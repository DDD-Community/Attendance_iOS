//
//  DefaultMyPageRepository.swift
//  DomainInterface
//
//  Created by 홍은표 on 1/12/26.
//

import Foundation

import Entity

final public class DefaultMyPageRepository: MyPageRepositoryInterface {
  public func fetchAttendances() async throws -> AttendanceSummaryResponse {
    return .init(
      totalAttended: 0,
      totalLate: 0,
      totalAbsent: 0
    )
  }
}
