//
//  DecodingFailure.swift
//  DDDNetworkInterface
//
//  Copyright © 2026 DDD. All rights reserved.
//

import Foundation

/// 응답 파싱 — 서버 객체를 클라 객체로 디코딩하다 실패.
public enum DecodingFailure: Error {
  /// 본문을 기대한 요청인데 응답 바디가 비어 있음 (`DDDEmptyResponse` 가 아닌 경우)
  case dataMissing
  /// 디코딩 자체 실패
  case failed(any Error)
}
