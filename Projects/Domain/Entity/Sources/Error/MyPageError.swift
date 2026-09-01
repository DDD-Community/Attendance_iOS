//
//  MyPageError.swift
//  Entity
//
//  Created by DDD on 9/1/26.
//

import Foundation

public enum MyPageError: Error, LocalizedError, Equatable {
  case networkError(String)
  case decodingError(String)
  case unauthorized
  case serverError(Int)
  case unknown(String)

  public var errorDescription: String? {
    switch self {
    case let .networkError(message):
      return "네트워크 오류: \(message)"
    case let .decodingError(message):
      return "데이터 파싱 오류: \(message)"
    case .unauthorized:
      return "권한이 없습니다"
    case let .serverError(code):
      return "서버 오류 (코드: \(code))"
    case let .unknown(message):
      return "알 수 없는 오류: \(message)"
    }
  }
}

public extension MyPageError {
  static func from(_ error: Error) -> MyPageError {
    if let myPageError = error as? MyPageError {
      return myPageError
    }
    return .unknown(error.localizedDescription)
  }
}
