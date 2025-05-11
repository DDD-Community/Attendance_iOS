//
//  RefreshTokenModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/9/25.
//

import Foundation

public typealias RefreshTokenModel = BaseResponse<RefreshTokenResponseModel>


public struct RefreshTokenResponseModel: Decodable {
  let refreshToken, accessToken: String?
  let user: User?
  
  // ✅ 실패 응답 필드
  let detail: String?
  let code: String?
  let messages: [TokenMessage]?
  
  enum CodingKeys: String, CodingKey {
    case refreshToken = "refresh_token"
    case accessToken = "access_token"
    case user
    case detail
    case code
    case messages
  }
}

// MARK: - 메시지 구조 (에러 케이스 전용)
public struct TokenMessage: Decodable {
  let tokenClass: String?
  let tokenType: String?
  let message: String?

  enum CodingKeys: String, CodingKey {
    case tokenClass = "token_class"
    case tokenType = "token_type"
    case message
  }
}
