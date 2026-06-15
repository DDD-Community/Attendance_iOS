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

  public func fetchParticipation(
    voteId: Int
  ) async throws -> VoteParticipation {
    VoteParticipation(voteId: voteId, totalMembers: 0, respondedMembers: 0, participationRate: 0)
  }

  public func participationStream(
    voteId _: Int,
    interval _: Double
  ) -> AsyncStream<VoteParticipation> {
    AsyncStream { $0.finish() }
  }

  public func fetchNonResponders(
    voteId _: Int
  ) async throws -> [NonParticipant] { [] }

  public func openVote(
    voteId _: Int
  ) async throws {}

  public func closeVote(
    voteId _: Int
  ) async throws {}

  public func createVote(
    input _: CreateVoteInput
  ) async throws -> Int { 0 }

  public func fetchTeamVoteResults(
    voteId: Int
  ) async throws -> TeamVoteResults {
    TeamVoteResults(voteId: voteId, title: "", status: .before, totalResponses: 0, categories: [])
  }

  public func fetchFeedbackResults(
    voteId: Int
  ) async throws -> FeedbackResults {
    FeedbackResults(voteId: voteId, totalResponses: 0, questions: [])
  }

  public func fetchActiveVote() async throws -> ActiveVote {
    ActiveVote(voteId: 0, title: "", alreadyResponded: false)
  }

  public func fetchTeamVoteTemplate(
    voteId _: Int
  ) async throws -> TeamVoteTemplateInfo {
    TeamVoteTemplateInfo(
      templateVersion: 0,
      status: .before,
      template: TeamVoteTemplate(title: "", description: "", notice: "", categories: []),
      teams: []
    )
  }

  public func fetchFeedbackTemplate(
    voteId _: Int
  ) async throws -> FeedbackTemplateInfo {
    FeedbackTemplateInfo(
      templateVersion: 0,
      status: .before,
      template: FeedbackTemplate(title: "", description: "", questions: [])
    )
  }

  public func submitVote(
    voteId _: Int,
    submission _: VoteSubmission
  ) async throws {}

  public func fetchMyResponse(
    voteId: Int
  ) async throws -> MyVoteResponse {
    MyVoteResponse(voteId: voteId, responded: false)
  }
}
