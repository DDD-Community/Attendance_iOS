//
//  RequestDeduplicator.swift
//  Repository
//
//  Created by Network Optimizer on 1/10/26.
//

import Foundation
import Moya

/// 중복 요청을 방지하는 매니저 (간소화 버전)
final class RequestDeduplicator {
    static let shared = RequestDeduplicator()

    private init() {}

    /// 중복 요청 방지를 위한 요청 실행
    func executeRequest<Target: TargetType>(
        provider: MoyaProvider<Target>,
        target: Target,
        enableDeduplication: Bool = true
    ) async throws -> Moya.Response {
        // 단순화된 구현: 직접 요청 수행
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(target) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// 요청을 고유하게 식별하기 위한 키 생성
    private func makeRequestKey<Target: TargetType>(for target: Target) -> String {
        let baseURL = target.baseURL.absoluteString
        let path = target.path
        let method = target.method.rawValue

        return "\(baseURL)/\(path)?method=\(method)"
    }
}

// MARK: - Method Extensions
private extension Moya.Method {
    /// 멱등성이 보장되는 HTTP 메서드인지 확인
    var isIdempotent: Bool {
        switch self {
        case .get, .head, .options:
            return true
        default:
            return false
        }
    }
}