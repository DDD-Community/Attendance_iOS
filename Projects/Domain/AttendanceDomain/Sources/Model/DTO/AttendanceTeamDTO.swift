//
//  AttendanceTeamDTO.swift
//  AttendanceDomain
//
//  Created by DDD on 9/3/26.
//

import Foundation

struct AttendanceTeamDTO: Decodable, Sendable {
  let teamId: Int
  let name: String
}
