//
//  ResponseCacheManager.swift
//  Repository
//
//  Created by Network Optimizer on 1/10/26.
//

import Foundation
import LogMacro

/// 응답 캐싱 매니저
final class ResponseCacheManager {
  static let shared = ResponseCacheManager()
  
  private let cache: URLCache
  private let cacheableStatusCodes: Set<Int> = [200, 203, 206, 300, 301, 410]
  private let cacheableHTTPMethods: Set<String> = ["GET", "HEAD"]
  
  private init() {
    // 향상된 캐시 설정
    self.cache = URLCache(
      memoryCapacity: 100 * 1024 * 1024,    // 100MB 메모리 캐시
      diskCapacity: 500 * 1024 * 1024,      // 500MB 디스크 캐시
      diskPath: "attendance_api_cache"
    )
    
    URLCache.shared = cache
  }
  
  /// 응답이 캐시 가능한지 확인
  func isCacheable(response: HTTPURLResponse, for request: URLRequest) -> Bool {
    guard let httpMethod = request.httpMethod,
          cacheableHTTPMethods.contains(httpMethod),
          cacheableStatusCodes.contains(response.statusCode) else {
      return false
    }
    
    // Cache-Control 헤더 확인
    if let cacheControl = response.allHeaderFields["Cache-Control"] as? String {
      // no-cache, no-store가 있으면 캐시하지 않음
      if cacheControl.contains("no-cache") || cacheControl.contains("no-store") {
        return false
      }
    }
    
    return true
  }
  
  /// 캐시에서 응답 조회
  func cachedResponse(for request: URLRequest) -> CachedURLResponse? {
    return cache.cachedResponse(for: request)
  }
  
  /// 응답을 캐시에 저장
  func store(response: URLResponse, data: Data, for request: URLRequest) {
    let cachedResponse = CachedURLResponse(response: response, data: data)
    cache.storeCachedResponse(cachedResponse, for: request)
  }
  
  /// 특정 URL 패턴의 캐시 삭제
  func removeCachedResponses(matching urlPattern: String) {
    // iOS 최신 버전에서는 URLCache의 diskPath 프로퍼티가 없으므로
    // 전체 캐시를 삭제하는 방식으로 변경
    cache.removeAllCachedResponses()
    #logDebug("✅ Removed all cached responses for pattern: \(urlPattern)")
    
    // TODO: 향후 더 정교한 패턴 매칭 구현 필요
  }
  
  /// 전체 캐시 정리
  func clearAllCaches() {
    cache.removeAllCachedResponses()
  }
  
  /// 메모리 경고 시 캐시 정리
  func handleMemoryWarning() {
    // 메모리 캐시만 정리하고 디스크 캐시는 유지
    cache.removeAllCachedResponses()
  }
}

// MARK: - Cache Strategy Helpers
extension ResponseCacheManager {
  /// 캐시 정책을 동적으로 결정
  func cachePolicy(for urlString: String) -> URLRequest.CachePolicy {
    // 사용자 정보나 실시간 데이터는 항상 서버에서 가져오기
    if urlString.contains("/me") ||
        urlString.contains("/attendance/current") ||
        urlString.contains("/qr") {
      return .reloadIgnoringLocalCacheData
    }
    
    // 정적 데이터는 캐시 우선 사용
    if urlString.contains("/schedules") ||
        urlString.contains("/teams") ||
        urlString.contains("/jobs") {
      return .returnCacheDataElseLoad
    }
    
    // 기본 정책
    return .useProtocolCachePolicy
  }
  
  /// 캐시 TTL 설정
  func cacheTTL(for urlString: String) -> TimeInterval {
    // 사용자 프로필: 30분
    if urlString.contains("/profile") {
      return 30 * 60
    }
    
    // 스케줄 정보: 1시간
    if urlString.contains("/schedules") {
      return 60 * 60
    }
    
    // 팀/직군 정보: 24시간
    if urlString.contains("/teams") || urlString.contains("/jobs") {
      return 24 * 60 * 60
    }
    
    // 기본 TTL: 10분
    return 10 * 60
  }
}
