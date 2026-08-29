//
//  NonRespondersDTO.swift
//  Model
//
//  Created by DDD on 6/11/26.
//

import Foundation

// MARK: - [운영진] 미참여 명단 (GET /votes/{id}/non-responders)

public struct NonRespondersDTO: Decodable {
  public let totalCount: Int?
  public let members: [NonResponderMemberDTO]?
}
