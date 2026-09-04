//
//  SelectTeamsDTO.swift
//  OnBoardingDomain
//
//  Created by DDD on 12/31/25.
//

import Foundation

public struct SelectTeamsDTO: Decodable, Sendable {
  public let data: [SelectTeamsDTOResponse]

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let array = try? container.decode([SelectTeamsDTOResponse].self) {
      self.data = array
      return
    }

    let keyed = try decoder.container(keyedBy: CodingKeys.self)
    self.data = try keyed.decode([SelectTeamsDTOResponse].self, forKey: .data)
  }

  private enum CodingKeys: String, CodingKey {
    case data
  }
}


public struct SelectTeamsDTOResponse: Decodable, Sendable {
  public let teamId: Int
  public let name: String
}
