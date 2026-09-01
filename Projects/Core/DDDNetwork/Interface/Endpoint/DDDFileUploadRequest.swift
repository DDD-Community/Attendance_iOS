//
//  DDDFileUploadRequest.swift
//  DDDNetworkInterface
//
//  Copyright © 2026 DDD. All rights reserved.
//

import Foundation

/// presigned URL 로의 원본 바이트 PUT 업로드 요청.
/// 앱 서버가 아니라 스토리지로 직접 올리는 경로라 baseURL 을 쓰지 않고 절대 URL 을 받는다.
public protocol DDDFileUploadRequest: Sendable {
  /// 업로드 대상 절대 URL (presigned)
  var uploadURL: URL { get }
  /// PUT 바디로 올릴 원본 바이트
  var body: Data { get }
  /// Content-Type 헤더 값
  var contentType: String { get }
  /// 타임아웃(초). nil 이면 세션 기본값 사용.
  var timeoutInterval: TimeInterval? { get }
}

public extension DDDFileUploadRequest {
  var timeoutInterval: TimeInterval? {
    return nil
  }
}
