//
//  SelectMangerRoleDTO.swift
//  Model
//
//  Created by Wonji Suh  on 1/1/26.
//

import Foundation

public struct SelectMangerRoleDTO: Decodable {
  public let data: [SelectMangerRoleDTOReponse]

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let array = try? container.decode([SelectMangerRoleDTOReponse].self) {
      self.data = array
      return
    }

    let keyed = try decoder.container(keyedBy: CodingKeys.self)
    self.data = try keyed.decode([SelectMangerRoleDTOReponse].self, forKey: .data)
  }

  private enum CodingKeys: String, CodingKey {
    case data
  }
}

public struct SelectMangerRoleDTOReponse: Decodable {
    let key, description: String
}
