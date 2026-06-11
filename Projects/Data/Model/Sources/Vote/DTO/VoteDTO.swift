//
//  VoteDTO.swift
//  Model
//
//  Created by Roy on 6/11/26.
//

import Foundation

public struct VoteListItemDTO: Decodable {
  public let voteId: Int?
  public let title: String?
  public let status: String?
  public let openedAt: String?
  public let closedAt: String?
  public let createdDate: String?
}

public struct VoteDetailDTO: Decodable {
  public let voteId: Int?
  public let title: String?
  public let status: String?
}

public struct VoteParticipationDTO: Decodable {
  public let voteId: Int?
  public let title: String?
  public let status: String?
  public let totalMembers: Int?
  public let respondedMembers: Int?
  public let participationRate: Int?
}

public struct NonRespondersDTO: Decodable {
  public let totalCount: Int?
  public let members: [NonResponderMemberDTO]?
}

public struct NonResponderMemberDTO: Decodable {
  public let memberId: Int?
  public let name: String?
  public let teamName: String?
}
