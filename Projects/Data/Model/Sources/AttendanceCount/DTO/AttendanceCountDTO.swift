//
//  AttendanceCountDTO.swift
//  Model
//
//  Created by DDD on 1/11/26.
//

import Foundation

public struct AttendanceCountDTO: Decodable {
    let totalAttended, totalLate, totalAbsent: Int
}
