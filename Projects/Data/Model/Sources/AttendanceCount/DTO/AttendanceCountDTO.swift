//
//  AttendanceCountDTO.swift
//  Model
//
//  Created by Wonji Suh  on 1/11/26.
//

import Foundation

public struct AttendanceCountDTO: Decodable {
    let totalAttended, totalLate, totalAbsent: Int
}
