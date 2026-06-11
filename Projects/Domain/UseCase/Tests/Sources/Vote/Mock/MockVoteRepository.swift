//
//  MockVoteRepository.swift
//  UseCaseTests
//
//  Created by Roy on 6/11/26.
//

@testable import DomainInterface
@testable import Entity
import Foundation

@MainActor
final class MockVoteRepository: VoteInterface {
  var fetchVotesCallCount = 0
  var participationCallCount = 0
  var nonRespondersCallCount = 0
  var openVoteCallCount = 0
  var closeVoteCallCount = 0

  private var votesResponse: Result<[Vote], Error>?
  private var participationResponse: Result<VoteParticipation, Error>?
  private var nonRespondersResponse: Result<[NonParticipant], Error>?
  private var openVoteResponse: Result<Void, Error>?
  private var closeVoteResponse: Result<Void, Error>?

  func fetchVotes() async throws -> [Vote] {
    fetchVotesCallCount += 1
    guard let votesResponse else { throw VoteError.unknown("not configured") }
    return try votesResponse.get()
  }

  func fetchParticipation(voteId _: Int) async throws -> VoteParticipation {
    participationCallCount += 1
    guard let participationResponse else { throw VoteError.unknown("not configured") }
    return try participationResponse.get()
  }

  func participationStream(voteId _: Int, interval _: Double) -> AsyncStream<VoteParticipation> {
    AsyncStream { continuation in
      if case let .success(participation) = participationResponse {
        continuation.yield(participation)
      }
      continuation.finish()
    }
  }

  func fetchNonResponders(voteId _: Int) async throws -> [NonParticipant] {
    nonRespondersCallCount += 1
    guard let nonRespondersResponse else { throw VoteError.unknown("not configured") }
    return try nonRespondersResponse.get()
  }

  func openVote(voteId _: Int) async throws {
    openVoteCallCount += 1
    guard let openVoteResponse else { throw VoteError.unknown("not configured") }
    try openVoteResponse.get()
  }

  func closeVote(voteId _: Int) async throws {
    closeVoteCallCount += 1
    guard let closeVoteResponse else { throw VoteError.unknown("not configured") }
    try closeVoteResponse.get()
  }

  func configureVotesSuccess(_ votes: [Vote]) { votesResponse = .success(votes) }
  func configureVotesFailure(_ error: Error) { votesResponse = .failure(error) }
  func configureParticipationSuccess(_ participation: VoteParticipation) {
    participationResponse = .success(participation)
  }

  func configureParticipationFailure(_ error: Error) { participationResponse = .failure(error) }
  func configureNonRespondersSuccess(_ members: [NonParticipant]) { nonRespondersResponse = .success(members) }
  func configureNonRespondersFailure(_ error: Error) { nonRespondersResponse = .failure(error) }
  func configureOpenVoteSuccess() { openVoteResponse = .success(()) }
  func configureOpenVoteFailure(_ error: Error) { openVoteResponse = .failure(error) }
  func configureCloseVoteSuccess() { closeVoteResponse = .success(()) }
  func configureCloseVoteFailure(_ error: Error) { closeVoteResponse = .failure(error) }
}
