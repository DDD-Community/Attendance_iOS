//
//  ScheduleDTOModel.swift
//  ScheduleDomain
//
//  Created by DDD on 5/9/25.
//

import Foundation

public struct ScheduleDTO: Decodable, Sendable {
  let data: [ScheduleDTOResponse]

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let array = try? container.decode([ScheduleDTOResponse].self) {
      self.data = array
      return
    }

    let keyed = try decoder.container(keyedBy: CodingKeys.self)
    self.data = try keyed.decode([ScheduleDTOResponse].self, forKey: .data)
  }

  private enum CodingKeys: String, CodingKey {
    case data
  }
}


public struct ScheduleDTOResponse: Decodable, Sendable {
    let id: Int
    let name, desc: String
    let year, month, day: Int
}
