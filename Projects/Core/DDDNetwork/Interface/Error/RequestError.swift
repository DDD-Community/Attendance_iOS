//
//  RequestError.swift
//  DDDNetworkInterface
//
//  Copyright © 2026 DDD. All rights reserved.
//

import Foundation

/// 전송 전 — URLRequest 생성 / 파라미터 인코딩 단계 오류.
public enum RequestError: Error {
  /// baseURL 이 없거나 경로 조합이 잘못됨
  case invalidURL
  /// 파라미터 인코딩 실패
  case encodingFailed(any Error)
}
