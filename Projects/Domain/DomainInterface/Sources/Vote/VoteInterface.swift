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
  func fetchVotes() async throws -> [Vote]
  func fetchParticipation(
    voteId: Int
  ) async throws -> VoteParticipation
  func participationStream(
    voteId: Int,
    interval: Double
  ) -> AsyncStream<VoteParticipation>
  func fetchNonResponders(
    voteId: Int
  ) async throws -> [NonParticipant]
  func openVote(
    voteId: Int
  ) async throws
  func closeVote(
    voteId: Int
  ) async throws
  func createVote(
    input: CreateVoteInput
  ) async throws -> Int
  func fetchTeamVoteResults(
    voteId: Int
  ) async throws -> TeamVoteResults
  func fetchFeedbackResults(
    voteId: Int
  ) async throws -> FeedbackResults

  // 멤버
  func fetchActiveVote() async throws -> ActiveVote
  func fetchTeamVoteTemplate(
    voteId: Int
  ) async throws -> TeamVoteTemplateInfo
  func fetchFeedbackTemplate(
    voteId: Int
  ) async throws -> FeedbackTemplateInfo
  func submitVote(
    voteId: Int,
    submission: VoteSubmission
  ) async throws
  func fetchMyResponse(
    voteId: Int
  ) async throws -> MyVoteResponse
}

public enum VoteRepositoryDependency: TestDependencyKey {

  public static var testValue: VoteInterface {
    DefaultVoteRepositoryImpl()
  }

  public static var previewValue: VoteInterface = testValue
}

public extension DependencyValues {
  var voteRepository: VoteInterface {
    get { self[VoteRepositoryDependency.self] }
    set { self[VoteRepositoryDependency.self] = newValue }
  }
}
