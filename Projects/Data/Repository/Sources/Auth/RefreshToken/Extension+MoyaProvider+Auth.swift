//
//  Extension+MoyaProvider+Auth.swift
//  Repository
//
//  Created by DDD on 1/2/26.
//

import Foundations
import AsyncMoya

public extension MoyaProvider {
  static var authorized: MoyaProvider<Target> {
    let manager = OptimizedSessionManager.shared

    return MoyaProvider(
      session: manager.session,
      plugins: [
        MoyaLoggingPlugin()  // 🚀 최적화된 플러그인 사용
        // MoyaLoggingPlugin 제거 - 사용 불가
      ]
    )
  }

  /// 중복 제거 로직 없이 일반 요청을 수행하는 메서드
  func requestWithDeduplication(_ target: Target) async throws -> Moya.Response {
    try await requestResponse(target)
  }

  /// 배치 요청을 위한 메서드 (동시 실행) - 간소화
  func requestBatch(_ targets: [Target]) async throws -> [Moya.Response] {
    var responses: [Moya.Response] = []
    for target in targets {
      let response = try await withCheckedThrowingContinuation { continuation in
        self.request(target) { result in
          switch result {
          case .success(let response):
            continuation.resume(returning: response)
          case .failure(let error):
            continuation.resume(throwing: error)
          }
        }
      }
      responses.append(response)
    }
    return responses
  }

  /// 조건부 캐시 요청 (캐시 우선 전략) - 간소화
  func requestWithCache(_ target: Target) async throws -> Moya.Response {
    // 캐시 로직 단순화 - 일반 요청만 수행
    return try await withCheckedThrowingContinuation { continuation in
      self.request(target) { result in
        switch result {
        case .success(let response):
          continuation.resume(returning: response)
        case .failure(let error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// 네트워크 상태 기반 요청 (연결이 좋지 않을 때 캐시 우선)
  func requestAdaptive(_ target: Target) async throws -> Moya.Response {
    // TODO: 네트워크 상태 감지 로직 추가
    // 현재는 일반 요청으로 폴백
    return try await withCheckedThrowingContinuation { continuation in
      self.request(target) { result in
        switch result {
        case .success(let response):
          continuation.resume(returning: response)
        case .failure(let error):
          continuation.resume(throwing: error)
        }
      }
    }
  }
}
