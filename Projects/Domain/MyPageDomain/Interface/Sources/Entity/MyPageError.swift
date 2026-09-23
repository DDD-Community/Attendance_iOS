//
//  MyPageError.swift
//  Entity
//
//  Created by DDD on 1/4/26.
//

import Foundation

/// 마이페이지 조회 실패.
/// 전송 관심사(네트워크·디코딩·HTTP 상태)는 DDDNetwork 가 소유하므로
/// 여기서 구분할 도메인 실패가 따로 없어 단일 케이스로 둔다.
public enum MyPageError: Error, LocalizedError, Equatable {
  case loadFailed

  public var errorDescription: String? {
    switch self {
    case .loadFailed:
      return "마이페이지 정보를 불러오지 못했습니다"
    }
  }
}
