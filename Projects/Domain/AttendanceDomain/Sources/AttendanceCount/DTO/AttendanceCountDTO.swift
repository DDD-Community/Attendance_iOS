//
//  AttendanceCountDTO.swift
//  AttendanceDomain
//
//  Created by DDD on 1/11/26.
//

import Foundation

public struct AttendanceCountDTO: Decodable, Sendable {
    let totalAttended, totalLate, totalAbsent: Int
}
