//
//  ScheduleListResponseDTO.swift
//  DDDAttendance
//
//  Created by eunpyo on 4/13/25.
//

import Foundation

public struct ScheduleListResponseDTO: Decodable {
  let schedules: [ScheduleResponse]
}
