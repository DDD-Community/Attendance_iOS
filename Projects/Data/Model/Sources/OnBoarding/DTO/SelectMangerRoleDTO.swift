//
//  SelectMangerRoleDTO.swift
//  Model
//
//  Created by DDD on 1/1/26.
//

import Foundation

public struct SelectMangerRoleDTO: Decodable {
  public let data: [SelectMangerRoleDTOResponse]

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let array = try? container.decode([SelectMangerRoleDTOResponse].self) {
      self.data = array
      return
    }

    let keyed = try decoder.container(keyedBy: CodingKeys.self)
    self.data = try keyed.decode([SelectMangerRoleDTOResponse].self, forKey: .data)
  }

  private enum CodingKeys: String, CodingKey {
    case data
  }
}

public struct SelectMangerRoleDTOResponse: Decodable {
    let key, description: String
}
