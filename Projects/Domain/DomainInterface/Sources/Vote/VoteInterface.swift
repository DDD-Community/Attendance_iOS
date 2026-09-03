//
//  VoteInterface.swift
//  DomainInterface
//
//  Created by DDD on 6/11/26.
//

import Entity
import Foundation

import Dependencies

public protocol VoteInterface: Sendable {
  func fetchVotes() async throws(VoteError) -> [Vote]
  func fetchParticipation(
    voteId: Int
  ) async throws(VoteError) -> VoteParticipation
  func participationStream(
    voteId: Int,
    interval: Double
  ) -> AsyncStream<VoteParticipation>
  func fetchNonResponders(
    voteId: Int
  ) async throws(VoteError) -> [NonParticipant]
  func openVote(
    voteId: Int
  ) async throws(VoteError)
  func closeVote(
    voteId: Int
  ) async throws(VoteError)
  func createVote(
    input: CreateVoteInput
  ) async throws(VoteError) -> Int
  func fetchTeamVoteResults(
    voteId: Int
  ) async throws(VoteError) -> TeamVoteResults
  func fetchFeedbackResults(
    voteId: Int
  ) async throws(VoteError) -> FeedbackResults

  // 멤버
  func fetchActiveVote() async throws(VoteError) -> ActiveVote
  func fetchTeamVoteTemplate(
    voteId: Int
  ) async throws(VoteError) -> TeamVoteTemplateInfo
  func fetchFeedbackTemplate(
    voteId: Int
  ) async throws(VoteError) -> FeedbackTemplateInfo
  func submitVote(
    voteId: Int,
    submission: VoteSubmission
  ) async throws(VoteError)
  func fetchMyResponse(
    voteId: Int
  ) async throws(VoteError) -> MyVoteResponse
}

public enum VoteRepositoryDependency: TestDependencyKey {

  public static var testValue: VoteInterface {
    MockVoteRepository()
  }

  public static var previewValue: VoteInterface = testValue
}

public extension DependencyValues {
  var voteRepository: VoteInterface {
    get { self[VoteRepositoryDependency.self] }
    set { self[VoteRepositoryDependency.self] = newValue }
  }
}
