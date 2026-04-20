//
//  NetworkPerformanceMonitor.swift
//  Repository
//
//  Created by Network Optimizer on 1/10/26.
//

import Foundation
import Moya
import LogMacro

/// 네트워킹 성능 모니터링
final class NetworkPerformanceMonitor {
    static let shared = NetworkPerformanceMonitor()

    private var requestMetrics: [String: RequestMetrics] = [:]
    private let queue = DispatchQueue(label: "network.monitor", qos: .utility)

    private init() {}

    /// 요청 시작 추적
    func trackRequestStart(for url: String, method: String) {
        queue.async { [weak self] in
            let metrics = RequestMetrics(
                url: url,
                method: method,
                startTime: CFAbsoluteTimeGetCurrent()
            )
            self?.requestMetrics[self?.requestKey(url: url, method: method) ?? ""] = metrics
        }
    }

    /// 요청 완료 추적
    func trackRequestComplete(
        for url: String,
        method: String,
        statusCode: Int,
        responseSize: Int64,
        fromCache: Bool = false
    ) {
        queue.async { [weak self] in
            let key = self?.requestKey(url: url, method: method) ?? ""
            guard var metrics = self?.requestMetrics[key] else { return }

            let endTime = CFAbsoluteTimeGetCurrent()
            metrics.endTime = endTime
            metrics.duration = endTime - metrics.startTime
            metrics.statusCode = statusCode
            metrics.responseSize = responseSize
            metrics.fromCache = fromCache

            self?.requestMetrics[key] = metrics
            self?.logPerformanceMetrics(metrics)

            // 성능 이슈 감지
            self?.detectPerformanceIssues(metrics)
        }
    }

    /// 요청 실패 추적
    func trackRequestFailure(for url: String, method: String, error: Error) {
        queue.async { [weak self] in
            let key = self?.requestKey(url: url, method: method) ?? ""
            guard var metrics = self?.requestMetrics[key] else { return }

            metrics.endTime = CFAbsoluteTimeGetCurrent()
            metrics.duration = metrics.endTime - metrics.startTime
            metrics.error = error

            self?.requestMetrics[key] = metrics
            self?.logErrorMetrics(metrics)
        }
    }

    /// 성능 통계 조회
    func getPerformanceStats() -> NetworkStats {
        return queue.sync {
            let allMetrics = Array(requestMetrics.values)
            let successfulRequests = allMetrics.filter { $0.statusCode != nil && $0.error == nil }

            guard !successfulRequests.isEmpty else {
                return NetworkStats(
                    totalRequests: allMetrics.count,
                    successfulRequests: 0,
                    averageResponseTime: 0,
                    cacheHitRate: 0,
                    slowestEndpoints: []
                )
            }

            let avgResponseTime = successfulRequests.reduce(0.0) { $0 + $1.duration } / Double(successfulRequests.count)
            let cacheHits = successfulRequests.filter { $0.fromCache }.count
            let cacheHitRate = Double(cacheHits) / Double(successfulRequests.count)

            // 가장 느린 엔드포인트 추출
            let slowestEndpoints = successfulRequests
                .sorted { $0.duration > $1.duration }
                .prefix(5)
                .map { SlowEndpoint(url: $0.url, averageTime: $0.duration) }

            return NetworkStats(
                totalRequests: allMetrics.count,
                successfulRequests: successfulRequests.count,
                averageResponseTime: avgResponseTime,
                cacheHitRate: cacheHitRate,
                slowestEndpoints: Array(slowestEndpoints)
            )
        }
    }

    private func requestKey(url: String, method: String) -> String {
        return "\(method):\(url)"
    }

    private func logPerformanceMetrics(_ metrics: RequestMetrics) {
        #logDebug("""
        📊 [Network Performance]
        URL: \(metrics.url)
        Method: \(metrics.method)
        Duration: \(String(format: "%.3f", metrics.duration))s
        Status: \(metrics.statusCode ?? 0)
        Size: \(metrics.responseSize) bytes
        From Cache: \(metrics.fromCache)
        """)
    }

    private func logErrorMetrics(_ metrics: RequestMetrics) {
        #logError("""
        ❌ [Network Error]
        URL: \(metrics.url)
        Method: \(metrics.method)
        Duration: \(String(format: "%.3f", metrics.duration))s
        Error: \(metrics.error?.localizedDescription ?? "Unknown")
        """)
    }

    private func detectPerformanceIssues(_ metrics: RequestMetrics) {
        // 3초 이상 걸리는 요청 감지
        if metrics.duration > 3.0 {
            #logError("🐌 Slow request detected: \(metrics.url) took \(String(format: "%.3f", metrics.duration))s")
        }

        // 응답 크기가 5MB 이상인 경우 경고
        if metrics.responseSize > 5 * 1024 * 1024 {
            #logError("📦 Large response detected: \(metrics.url) - \(metrics.responseSize) bytes")
        }
    }
}

// MARK: - Data Models
struct RequestMetrics {
    let url: String
    let method: String
    let startTime: CFAbsoluteTime
    var endTime: CFAbsoluteTime = 0
    var duration: TimeInterval = 0
    var statusCode: Int?
    var responseSize: Int64 = 0
    var fromCache: Bool = false
    var error: Error?
}

struct NetworkStats {
    let totalRequests: Int
    let successfulRequests: Int
    let averageResponseTime: TimeInterval
    let cacheHitRate: Double
    let slowestEndpoints: [SlowEndpoint]
}

struct SlowEndpoint {
    let url: String
    let averageTime: TimeInterval
}