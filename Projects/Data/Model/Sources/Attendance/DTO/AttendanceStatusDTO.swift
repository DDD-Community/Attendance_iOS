//
//  AttendanceStatusDTO.swift
//  Model
//
//  Created by Wonji Suh  on 1/13/26.
//

import Foundation

public struct AttendanceStatusDTO: Decodable {
  let data: [AttendanceStatusDTOResponse]

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let array = try? container.decode([AttendanceStatusDTOResponse].self) {
      self.data = array
      return
    }

    let keyed = try decoder.container(keyedBy: CodingKeys.self)
    self.data = try keyed.decode([AttendanceStatusDTOResponse].self, forKey: .data)
  }

  private enum CodingKeys: String, CodingKey {
    case data
  }
}

public struct AttendanceStatusDTOResponse: Decodable {
    let name, code: String
}

