//
//  OptimizedMoyaPlugin.swift
//  Repository
//
//  Created by Network Optimizer on 1/10/26.
//

import Foundation
import AsyncMoya
import LogMacro

/// 네트워킹 최적화를 위한 통합 플러그인
final class OptimizedMoyaPlugin: PluginType {
  
  func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
    var optimizedRequest = request
    
    // 1. 압축 활성화
    optimizedRequest.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
    
    // 2. 캐시 정책 적용
    if let url = request.url?.absoluteString {
      optimizedRequest.cachePolicy = ResponseCacheManager.shared.cachePolicy(for: url)
    }
    
    // 3. 타임아웃 최적화
    optimizedRequest.timeoutInterval = getOptimalTimeout(for: target)
    
    // 4. User-Agent 설정
    if optimizedRequest.value(forHTTPHeaderField: "User-Agent") == nil {
      optimizedRequest.setValue(getUserAgent(), forHTTPHeaderField: "User-Agent")
    }
    
    // 5. 네트워크 추적 시작
    NetworkPerformanceMonitor.shared.trackRequestStart(
      for: target.path,
      method: target.method.rawValue
    )
    
    return optimizedRequest
  }
  
  func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
    switch result {
    case .success(let response):
      // 성공 시 캐싱 및 성능 추적
      handleSuccessResponse(response, target: target)
      
    case .failure(let error):
      // 실패 시 성능 추적
      NetworkPerformanceMonitor.shared.trackRequestFailure(
        for: target.path,
        method: target.method.rawValue,
        error: error
      )
      
      #logDebug("🚨 [Network Error] \(target.path): \(error.localizedDescription)")
    }
  }
  
  private func handleSuccessResponse(_ response: Response, target: TargetType) {
    // 응답 캐싱 (적절한 조건에서)
    if let request = response.request {
      let cacheManager = ResponseCacheManager.shared
      if cacheManager.isCacheable(response: response.response ?? HTTPURLResponse(), for: request) {
        cacheManager.store(
          response: response.response ?? HTTPURLResponse(),
          data: response.data,
          for: request
        )
      }
    }
    
    // 성능 메트릭 기록
    let isFromCache = response.response?.value(forHTTPHeaderField: "X-Cache") != nil
    NetworkPerformanceMonitor.shared.trackRequestComplete(
      for: target.path,
      method: target.method.rawValue,
      statusCode: response.statusCode,
      responseSize: Int64(response.data.count),
      fromCache: isFromCache
    )
    
    // 응답 크기 최적화 경고
    if response.data.count > 1024 * 1024 { // 1MB 초과
      #logError("📦 Large response detected: \(target.path) - \(response.data.count) bytes")
    }
  }
  
  private func getOptimalTimeout(for target: TargetType) -> TimeInterval {
    // URL path에 따라 타임아웃 조정
    switch target.path {
    case let path where path.contains("login") || path.contains("refresh"):
      return 15.0 // 인증 요청은 빠르게
    case let path where path.contains("upload"):
      return 60.0 // 업로드는 길게
    case let path where path.contains("qr"):
      return 10.0 // QR 관련은 빠르게
    default:
      return 30.0 // 기본 30초
    }
  }
  
  private func getUserAgent() -> String {
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    let appBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    let processInfo = ProcessInfo.processInfo
    let osVersion = processInfo.operatingSystemVersionString
    
    return "AttendanceApp/\(appVersion) (\(appBuild)) iOS/\(osVersion)"
  }
}

// MARK: - Cache Header Helper
private extension HTTPURLResponse {
  func isCacheableResponse() -> Bool {
    // Cache-Control 헤더 확인
    if let cacheControl = allHeaderFields["Cache-Control"] as? String {
      return !cacheControl.contains("no-cache") && !cacheControl.contains("no-store")
    }
    
    // ETag 또는 Last-Modified 헤더가 있으면 캐시 가능
    return allHeaderFields["ETag"] != nil || allHeaderFields["Last-Modified"] != nil
  }
}
