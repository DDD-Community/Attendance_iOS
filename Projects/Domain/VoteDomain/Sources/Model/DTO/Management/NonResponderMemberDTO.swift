//
//  NonResponderMemberDTO.swift
//  VoteDomain
//
//  Created by DDD on 6/11/26.
//

import Foundation

public struct NonResponderMemberDTO: Decodable, Sendable {
  public let memberId: Int?
  public let name: String?
  public let teamName: String?
}
