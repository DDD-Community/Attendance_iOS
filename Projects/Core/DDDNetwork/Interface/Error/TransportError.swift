//
//  TransportError.swift
//  DDDNetworkInterface
//
//  Copyright © 2026 DDD. All rights reserved.
//

import Foundation

/// 전송 중 — 연결 / 타임아웃 / 취소 등 전송 자체 실패.
public enum TransportError: Error {
  /// 네트워크 연결 없음 (오프라인 등)
  case notConnected
  /// 타임아웃
  case timedOut
  /// 요청 취소
  case cancelled
  /// 그 외 전송 실패
  case unknown(any Error)
}
