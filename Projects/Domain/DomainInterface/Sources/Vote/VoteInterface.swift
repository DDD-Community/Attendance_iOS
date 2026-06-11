//
//  VoteInterface.swift
//  DomainInterface
//
//  Created by Roy on 6/11/26.
//

import Entity
import Foundation
import WeaveDI

public protocol VoteInterface: Sendable {
  func fetchVotes() async throws -> [Vote]
  func fetchParticipation(voteId: Int) async throws -> VoteParticipation
  func participationStream(voteId: Int, interval: Double) -> AsyncStream<VoteParticipation>
  func fetchNonResponders(voteId: Int) async throws -> [NonParticipant]
  func openVote(voteId: Int) async throws
  func closeVote(voteId: Int) async throws
}

public struct VoteRepositoryDependency: DependencyKey {
  public static var liveValue: VoteInterface {
    UnifiedDI.resolve(VoteInterface.self) ?? DefaultVoteRepositoryImpl()
  }

  public static var testValue: VoteInterface {
    UnifiedDI.resolve(VoteInterface.self) ?? DefaultVoteRepositoryImpl()
  }

  public static var previewValue: VoteInterface = liveValue
}

public extension DependencyValues {
  var voteRepository: VoteInterface {
    get { self[VoteRepositoryDependency.self] }
    set { self[VoteRepositoryDependency.self] = newValue }
  }
}
