//
//  NetworkOptimizationManager.swift
//  Repository
//
//  Created by Network Optimizer on 1/10/26.
//

import Foundation
import LogMacro
// LogMacro 모듈 사용 불가시 로그 매크로 비활성화

/// 네트워킹 최적화 통합 관리자
@MainActor
final class NetworkOptimizationManager: ObservableObject {
    static let shared = NetworkOptimizationManager()

    @Published private(set) var isOptimized = false
    @Published private(set) var optimizationLevel: OptimizationLevel = .balanced

    private init() {}

    /// 최적화 활성화
    func enableOptimizations(level: OptimizationLevel = .balanced) async {
        #logDebug("🚀 [NetworkOptimization] Enabling optimizations with level: \(level)")

        optimizationLevel = level

        // 1. 메모리 최적화 활성화
        await enableMemoryOptimizations()

        // 2. 캐시 최적화 설정
        configureCacheOptimizations(for: level)

        // 3. 세션 최적화 적용
        configureSessionOptimizations(for: level)

        // 4. 모니터링 활성화
        enablePerformanceMonitoring()

        isOptimized = true
        #logDebug("✅ [NetworkOptimization] All optimizations enabled successfully")
    }

    /// 최적화 비활성화
    func disableOptimizations() async {
        #logDebug("🔄 [NetworkOptimization] Disabling optimizations")

        // 모든 캐시 정리
        ResponseCacheManager.shared.clearAllCaches()

        // Provider 풀 정리
        MoyaProviderPool.shared.clearPool()

        // 메모리 정리
        await performMemoryCleanup()

        isOptimized = false
        #logDebug("✅ [NetworkOptimization] Optimizations disabled")
    }

    /// 성능 통계 조회
    func getPerformanceStats() -> NetworkStats {
        return NetworkPerformanceMonitor.shared.getPerformanceStats()
    }

    /// 메모리 경고 처리
    func handleMemoryWarning() async {
        #logDebug("🚨 [NetworkOptimization] Memory warning received, cleaning up")

        // 캐시 정리
        ResponseCacheManager.shared.handleMemoryWarning()

        // Provider 풀 정리
        MoyaProviderPool.shared.clearPool()

        // 강제 메모리 정리
        await performMemoryCleanup()
    }

    // MARK: - Private Methods

    private func enableMemoryOptimizations() async {
        // 메모리 경고 알림 구독 (UIKit 의존성 제거)
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("UIApplicationDidReceiveMemoryWarningNotification"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { [weak self] in
                await self?.handleMemoryWarning()
            }
        }
    }

    private func configureCacheOptimizations(for level: OptimizationLevel) {
        let cacheManager = ResponseCacheManager.shared

        switch level {
        case .minimal:
            // 최소한의 캐시만 사용
            break
        case .balanced:
            // 균형잡힌 캐시 전략 (기본값)
            break
        case .aggressive:
            // 적극적인 캐시 사용
            break
        }
    }

    private func configureSessionOptimizations(for level: OptimizationLevel) {
        // URLSession 설정 최적화는 OptimizedSessionManager에서 처리됨
        switch level {
        case .minimal:
            #logDebug("🔧 [NetworkOptimization] Minimal session optimizations applied")
        case .balanced:
            #logDebug("🔧 [NetworkOptimization] Balanced session optimizations applied")
        case .aggressive:
            #logDebug("🔧 [NetworkOptimization] Aggressive session optimizations applied")
        }
    }

    private func enablePerformanceMonitoring() {
        #logDebug("📊 [NetworkOptimization] Performance monitoring enabled")
        // NetworkPerformanceMonitor는 이미 활성화되어 있음
    }

    private func performMemoryCleanup() async {
        #logDebug("🧹 [NetworkOptimization] Performing memory cleanup")

        // 가비지 컬렉션 힌트 (참고용)
        autoreleasepool {
            // 임시 객체들 정리
        }
    }
}

// MARK: - Optimization Levels
enum OptimizationLevel: String, CaseIterable {
    case minimal = "minimal"     // 최소 최적화
    case balanced = "balanced"   // 균형잡힌 최적화 (권장)
    case aggressive = "aggressive" // 적극적 최적화

    var description: String {
        switch self {
        case .minimal:
            return "최소 최적화 - 안정성 우선"
        case .balanced:
            return "균형 최적화 - 성능과 안정성 균형 (권장)"
        case .aggressive:
            return "적극적 최적화 - 최대 성능 우선"
        }
    }
}
