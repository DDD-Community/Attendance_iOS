//
//  SelectJobsDTO.swift
//  Model
//
//  Created by DDD on 12/30/25.
//

//public typealias SelectJobsDTO = [SelectJobsDTOResponse]

public struct SelectJobsDTO: Decodable, Sendable {
  public let data: [SelectJobsDTOResponse]

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let array = try? container.decode([SelectJobsDTOResponse].self) {
      self.data = array
      return
    }

    let keyed = try decoder.container(keyedBy: CodingKeys.self)
    self.data = try keyed.decode([SelectJobsDTOResponse].self, forKey: .data)
  }

  private enum CodingKeys: String, CodingKey {
    case data
  }
}


public struct SelectJobsDTOResponse: Decodable, Sendable {
    public let key: String
    public let description: String
}
