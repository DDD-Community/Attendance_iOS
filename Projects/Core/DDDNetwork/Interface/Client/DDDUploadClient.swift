//
//  DDDUploadClient.swift
//  DDDNetworkInterface
//
//  Copyright © 2026 DDD. All rights reserved.
//

import Foundation

/// 멀티파트 업로드 진입점. 일반 요청과 분리해, 업로드가 필요한 곳만 의존한다.
public protocol DDDUploadClient: Sendable {
  /// 멀티파트 요청을 전송하고 디코딩된 응답을 반환한다.
  func upload<R: DDDUploadRequest>(_ request: R) async throws(DDDNetworkError) -> R.Response
}
