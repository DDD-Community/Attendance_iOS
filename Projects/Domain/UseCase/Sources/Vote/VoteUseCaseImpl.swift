//
//  VoteUseCaseImpl.swift
//  UseCase
//
//  Created by DDD on 6/11/26.
//

import DomainInterface
import Entity
import WeaveDI

public struct VoteUseCaseImpl: VoteInterface {
  @Dependency(\.voteRepository) var repository

  public init() {}

  // MARK: - [운영진] 투표 관리 API (MANAGER 토큰)

  /// 본인 기수 투표 목록 조회 (GET /votes)
  public func fetchVotes() async throws -> [Vote] {
    try await repository.fetchVotes()
  }

  /// 투표 상태 + 참여 현황 조회 (GET /votes/{id}/participation)
  public func fetchParticipation(
    voteId: Int
  ) async throws -> VoteParticipation {
    try await repository.fetchParticipation(voteId: voteId)
  }

  /// 참여 현황 실시간 폴링 스트림 (진행 중 화면 갱신용)
  public func participationStream(
    voteId: Int,
    interval: Double = 5
  ) -> AsyncStream<VoteParticipation> {
    repository.participationStream(voteId: voteId, interval: interval)
  }

  /// 미참여 멤버 명단 조회 (GET /votes/{id}/non-responders)
  public func fetchNonResponders(
    voteId: Int
  ) async throws -> [NonParticipant] {
    try await repository.fetchNonResponders(voteId: voteId)
  }

  /// 투표 시작 — DRAFT → OPEN (PATCH /votes/{id}/open)
  public func openVote(
    voteId: Int
  ) async throws {
    try await repository.openVote(voteId: voteId)
  }

  /// 투표 종료 — OPEN → CLOSED (PATCH /votes/{id}/close)
  public func closeVote(
    voteId: Int
  ) async throws {
    try await repository.closeVote(voteId: voteId)
  }

  /// 투표 생성 — DRAFT 생성 (POST /votes)
  public func createVote(
    input: CreateVoteInput
  ) async throws -> Int {
    try await repository.createVote(input: input)
  }

  /// 팀 투표 결과 집계 조회 (GET /votes/{id}/team-vote/results)
  public func fetchTeamVoteResults(
    voteId: Int
  ) async throws -> TeamVoteResults {
    try await repository.fetchTeamVoteResults(voteId: voteId)
  }

  /// 피드백 결과 집계 조회 (GET /votes/{id}/feedback/results)
  public func fetchFeedbackResults(
    voteId: Int
  ) async throws -> FeedbackResults {
    try await repository.fetchFeedbackResults(voteId: voteId)
  }

  // MARK: - [멤버] 투표 참여 API (MEMBER 토큰)

  /// 내 기수 진행 중(OPEN) 투표 조회 (GET /votes/active)
  public func fetchActiveVote() async throws -> ActiveVote {
    try await repository.fetchActiveVote()
  }

  /// 팀 투표 템플릿 + 팀 목록 조회 (GET /votes/{id}/team-vote/template)
  public func fetchTeamVoteTemplate(
    voteId: Int
  ) async throws -> TeamVoteTemplateInfo {
    try await repository.fetchTeamVoteTemplate(voteId: voteId)
  }

  /// 피드백 템플릿 조회 (GET /votes/{id}/feedback/template)
  public func fetchFeedbackTemplate(
    voteId: Int
  ) async throws -> FeedbackTemplateInfo {
    try await repository.fetchFeedbackTemplate(voteId: voteId)
  }

  /// 투표 제출 — 팀투표 + 피드백 동시 제출 (POST /votes/{id}/responses)
  public func submitVote(
    voteId: Int,
    submission: VoteSubmission
  ) async throws {
    try await repository.submitVote(voteId: voteId, submission: submission)
  }

  /// 내 참여 여부 조회 (GET /votes/{id}/responses/me)
  public func fetchMyResponse(
    voteId: Int
  ) async throws -> MyVoteResponse {
    try await repository.fetchMyResponse(voteId: voteId)
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
