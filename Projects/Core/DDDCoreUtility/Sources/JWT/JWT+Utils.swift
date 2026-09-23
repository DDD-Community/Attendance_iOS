//
//  JWT+Utils.swift
//  Utill
//
//  Created by DDD on 1/4/26.
//

import Foundation

public enum JWTUtils {
  /// JWT 토큰의 만료 시간을 추출
  public static func expirationDate(from token: String) -> Date? {
    struct Payload: Decodable {
      let exp: TimeInterval?
    }
    
    let segments = token.split(separator: ".")
    guard segments.count > 1 else { return nil }
    
    var payload = String(segments[1])
    payload = payload.replacingOccurrences(of: "-", with: "+")
    payload = payload.replacingOccurrences(of: "_", with: "/")
    let remainder = payload.count % 4
    if remainder > 0 {
      payload += String(repeating: "=", count: 4 - remainder)
    }
    
    guard let data = Data(base64Encoded: payload),
          let decoded = try? JSONDecoder().decode(Payload.self, from: data),
          let exp = decoded.exp
    else {
      return nil
    }
    
    return Date(timeIntervalSince1970: exp)
  }
  
  /// JWT 토큰의 전체 payload를 추출
  public static func decodePayload(from token: String) -> [String: Any]? {
    let segments = token.split(separator: ".")
    guard segments.count == 3 else { return nil }
    
    var payload = String(segments[1])
    payload = payload.replacingOccurrences(of: "-", with: "+")
    payload = payload.replacingOccurrences(of: "_", with: "/")
    let remainder = payload.count % 4
    if remainder > 0 {
      payload += String(repeating: "=", count: 4 - remainder)
    }
    
    guard let data = Data(base64Encoded: payload),
          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    else {
      return nil
    }
    
    return json
  }
  
  /// JWT 토큰에서 특정 필드 값을 추출
  public static func getValue<T>(from token: String, forKey key: String) -> T? {
    guard let payload = decodePayload(from: token) else { return nil }
    return payload[key] as? T
  }
  
  /// JWT 토큰에서 type 필드를 추출 (member, manager 등)
  public static func getUserType(from token: String) -> String? {
    return getValue(from: token, forKey: "type")
  }
  
  /// JWT 토큰이 만료되었는지 확인
  public static func isExpired(_ token: String) -> Bool {
    guard let expirationDate = expirationDate(from: token) else { return true }
    return Date() >= expirationDate
  }
  
  /// JWT 토큰 디버깅용 - payload 전체 출력
  public static func debugPayload(from token: String) {
    if let payload = decodePayload(from: token) {
      print("🔍 JWT Payload:")
      for (key, value) in payload.sorted(by: { $0.key < $1.key }) {
        print("  \(key): \(value)")
      }
      
      // type 필드 확인
      if let type = getUserType(from: token) {
        print("✅ type 필드 발견: \(type)")
      } else {
        print("❌ type 필드가 없습니다")
      }
      
      // 만료 시간 확인
      if let expiration = expirationDate(from: token) {
        print("⏰ 만료 시간: \(expiration)")
        print("⏰ 현재 시간: \(Date())")
        print("⏰ 만료 여부: \(isExpired(token) ? "만료됨" : "유효함")")
      }
    } else {
      print("❌ JWT 디코딩 실패")
    }
  }
}
