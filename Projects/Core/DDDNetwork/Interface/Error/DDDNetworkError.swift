//
//  DDDNetworkError.swift
//  DDDNetworkInterface
//
//  Copyright © 2026 DDD. All rights reserved.
//

import Foundation

/// 네트워크 도메인 에러. 요청 파이프라인의 "어느 단계"에서 깨졌는지로 분류한다.
public enum DDDNetworkError: Error {
  /// 전송 전 — URLRequest 생성 / 파라미터 인코딩 단계 오류
  case request(RequestError)
  /// 전송 중 — 연결 실패 / 타임아웃 / 취소 등
  case transport(TransportError)
  /// 서버가 명시적으로 내려준 에러 응답 (4xx/5xx)
  case response(ResponseError)
  /// 응답 파싱 — 서버 객체를 클라 객체로 디코딩하다 실패
  case decoding(DecodingFailure)
}
