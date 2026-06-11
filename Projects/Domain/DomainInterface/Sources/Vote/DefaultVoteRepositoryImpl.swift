//
//  DefaultVoteRepositoryImpl.swift
//  DomainInterface
//
//  Created by Roy on 6/11/26.
//

import Entity

public final class DefaultVoteRepositoryImpl: VoteInterface {
  public init() {}

  public func fetchVotes() async throws -> [Vote] { [] }

  public func fetchParticipation(voteId: Int) async throws -> VoteParticipation {
    VoteParticipation(voteId: voteId, totalMembers: 0, respondedMembers: 0, participationRate: 0)
  }

  public func participationStream(voteId _: Int, interval _: Double) -> AsyncStream<VoteParticipation> {
    AsyncStream { $0.finish() }
  }

  public func fetchNonResponders(voteId _: Int) async throws -> [NonParticipant] { [] }

  public func openVote(voteId _: Int) async throws {}

  public func closeVote(voteId _: Int) async throws {}
}
