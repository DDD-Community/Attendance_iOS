//
//  VoteUseCaseImpl.swift
//  UseCase
//
//  Created by Roy on 6/11/26.
//

import DomainInterface
import Entity
import WeaveDI

public struct VoteUseCaseImpl: VoteInterface {
  @Dependency(\.voteRepository) var repository

  public init() {}

  public func fetchVotes() async throws -> [Vote] {
    try await repository.fetchVotes()
  }

  public func fetchParticipation(voteId: Int) async throws -> VoteParticipation {
    try await repository.fetchParticipation(voteId: voteId)
  }

  public func participationStream(voteId: Int, interval: Double = 5) -> AsyncStream<VoteParticipation> {
    repository.participationStream(voteId: voteId, interval: interval)
  }

  public func fetchNonResponders(voteId: Int) async throws -> [NonParticipant] {
    try await repository.fetchNonResponders(voteId: voteId)
  }

  public func openVote(voteId: Int) async throws {
    try await repository.openVote(voteId: voteId)
  }

  public func closeVote(voteId: Int) async throws {
    try await repository.closeVote(voteId: voteId)
  }
}

extension VoteUseCaseImpl: DependencyKey {
  public static var liveValue: VoteInterface = VoteUseCaseImpl()
  public static var testValue: VoteInterface = VoteUseCaseImpl()
  public static var previewValue: VoteInterface = liveValue
}

public extension DependencyValues {
  var voteUseCase: VoteInterface {
    get { self[VoteUseCaseImpl.self] }
    set { self[VoteUseCaseImpl.self] = newValue }
  }
}
