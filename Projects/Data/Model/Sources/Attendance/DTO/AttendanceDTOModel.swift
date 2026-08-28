//
//  AttendanceDTOModel.swift
//  Model
//
//  Created by DDD on 1/11/26.
//

import Foundation

public struct AttendanceDTOModel: Decodable {
  let data: [AttendanceDTOResponse]

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let array = try? container.decode([AttendanceDTOResponse].self) {
      self.data = array
      return
    }

    let keyed = try decoder.container(keyedBy: CodingKeys.self)
    self.data = try keyed.decode([AttendanceDTOResponse].self, forKey: .data)
  }

  private enum CodingKeys: String, CodingKey {
    case data
  }
}



public struct AttendanceDTOResponse: Decodable {
  let attendanceID: Int?
  let userID: Int
  let userName, userInfo: String
  let attendanceStatus: String

  enum CodingKeys: String, CodingKey {
    case attendanceID = "attendanceId"
    case userID = "userId"
    case userName, userInfo, attendanceStatus
  }
}


