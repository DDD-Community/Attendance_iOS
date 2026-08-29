//
//  Encodable+.swift
//  Service
//
//  Created by DDD on 12/29/25.
//

import Foundation

extension Encodable {
  var toDictionary: [String: Any]? {
    guard let data = try? JSONEncoder().encode(self) else { return nil }
    return try? JSONSerialization.jsonObject(with: data) as? [String: Any]
  }
}

extension String {
  /// 문자열을 지정된 키로 API 파라미터용 Dictionary로 변환
  func toDictionary(key: String) -> [String: Any] {
    return [key: self]
  }
}

extension Int {
  func toDictionary(key: String) -> [String: Any] {
    [key: self]
  }
}
