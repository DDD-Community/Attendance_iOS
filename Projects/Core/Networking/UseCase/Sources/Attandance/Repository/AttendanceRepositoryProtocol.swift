//
//  AttendanceRepositoryProtocol.swift
//  UseCase
//
//  Created by Wonji Suh  on 5/10/25.
//

import Model

public protocol AttendanceRepositoryProtocol {
  func attendanceCount(startDate: String) async throws -> AttendanceCountDTOModel?
}


