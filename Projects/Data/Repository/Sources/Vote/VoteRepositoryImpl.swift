//
//  VoteRepositoryImpl.swift
//  Repository
//
//  Created by Roy on 6/11/26.
//

import DomainInterface
import Entity
import Model

import Service

@preconcurrency import AsyncMoya

public final class VoteRepositoryImpl: VoteInterface, @unchecked Sendable {
  private let provider: MoyaProvider<VoteService>

  public init(
    provider: MoyaProvider<VoteService>? = nil
  ) {
    self.provider = provider ?? MoyaProviderPool.shared.authorizedProvider(for: VoteService.self)
  }

  public func fetchVotes() async throws -> [Vote] {
    let response = try await provider.requestResponse(.list)
    try validate(response)
    return try decode([VoteListItemDTO].self, from: response.data).toDomain()
  }

  public func fetchParticipation(voteId: Int) async throws -> VoteParticipation {
    let response = try await provider.requestResponse(.participation(voteId: voteId))
    try validate(response)
    return try decode(VoteParticipationDTO.self, from: response.data).toDomain()
  }

  public func participationStream(voteId: Int, interval: Double) -> AsyncStream<VoteParticipation> {
    AsyncStream { continuation in
      let task = _Concurrency.Task {
        while !_Concurrency.Task.isCancelled {
          if let participation = try? await fetchParticipation(voteId: voteId) {
            continuation.yield(participation)
          }
          try? await _Concurrency.Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
        }
        continuation.finish()
      }
      continuation.onTermination = { _ in task.cancel() }
    }
  }

  public func fetchNonResponders(voteId: Int) async throws -> [NonParticipant] {
    let response = try await provider.requestResponse(.nonResponders(voteId: voteId))
    try validate(response)
    return try decode(NonRespondersDTO.self, from: response.data).toDomain()
  }

  public func openVote(voteId: Int) async throws {
    let response = try await provider.requestResponse(.open(voteId: voteId))
    try validate(response)
  }

  public func closeVote(voteId: Int) async throws {
    let response = try await provider.requestResponse(.close(voteId: voteId))
    try validate(response)
  }
}

private extension VoteRepositoryImpl {
  struct ErrorBody: Decodable {
    let code: String?
    let message: String?
  }

  func validate(_ response: Response) throws {
    guard !(200 ..< 300).contains(response.statusCode) else { return }
    let body = try? JSONDecoder().decode(ErrorBody.self, from: response.data)
    throw VoteError.from(statusCode: response.statusCode, code: body?.code, message: body?.message)
  }

  func decode<T: Decodable>(_: T.Type, from data: Data) throws -> T {
    do {
      return try JSONDecoder().decode(T.self, from: data)
    } catch {
      throw VoteError.unknown("응답을 해석할 수 없습니다")
    }
  }
}
