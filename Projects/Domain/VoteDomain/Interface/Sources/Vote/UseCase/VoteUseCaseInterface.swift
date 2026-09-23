//
//  VoteUseCaseInterface.swift
//  VoteDomainInterface
//

import Dependencies
//  Created by DDD on 9/3/26.
//

public protocol VoteUseCaseInterface: Sendable {
  func fetchVotes() async throws(VoteError) -> [Vote]
  func fetchParticipation(voteId: Int) async throws(VoteError) -> VoteParticipation
  func participationStream(voteId: Int, interval: Double) -> AsyncStream<VoteParticipation>
  func fetchNonResponders(voteId: Int) async throws(VoteError) -> [NonParticipant]
  func openVote(voteId: Int) async throws(VoteError)
  func closeVote(voteId: Int) async throws(VoteError)
  func createVote(input: CreateVoteInput) async throws(VoteError) -> Int
  func fetchTeamVoteResults(voteId: Int) async throws(VoteError) -> TeamVoteResults
  func fetchFeedbackResults(voteId: Int) async throws(VoteError) -> FeedbackResults
  func fetchActiveVote() async throws(VoteError) -> ActiveVote
  func fetchTeamVoteTemplate(voteId: Int) async throws(VoteError) -> TeamVoteTemplateInfo
  func fetchFeedbackTemplate(voteId: Int) async throws(VoteError) -> FeedbackTemplateInfo
  func submitVote(voteId: Int, submission: VoteSubmission) async throws(VoteError)
  func fetchMyResponse(voteId: Int) async throws(VoteError) -> MyVoteResponse
}

extension MockVoteRepository: VoteUseCaseInterface {}

public enum VoteUseCaseDependency: TestDependencyKey {
  public static let testValue: any VoteUseCaseInterface = MockVoteRepository()
  public static let previewValue: any VoteUseCaseInterface = testValue
}

public extension DependencyValues {
  var voteUseCase: any VoteUseCaseInterface {
    get { self[VoteUseCaseDependency.self] }
    set { self[VoteUseCaseDependency.self] = newValue }
  }
}
