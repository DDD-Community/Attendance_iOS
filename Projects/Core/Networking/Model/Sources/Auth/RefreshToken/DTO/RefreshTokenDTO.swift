//
//  RefreshTokenDTO.swift
//  Model
//
//  Created by Wonji Suh  on 5/9/25.
//

import Foundation

public typealias RefreshTokenDTOModel = BaseResponseDTO<RefreshTokenDTPResponseModel>

public struct RefreshTokenDTPResponseModel: Decodable,Equatable {
  public let refreshToken, accessToken: String
  public let user: UserDTO

  // ✅ 실패 응답 필드
  public let detail: String?
  public let code: String?
  public let messages: [TokenMessageDTO]?
  
  public init(
    refreshToken: String,
    accessToken: String,
    user: UserDTO,
    detail: String?,
    code: String?,
    messages: [TokenMessageDTO]?
  ) {
    self.refreshToken = refreshToken
    self.accessToken = accessToken
    self.user = user
    self.detail = detail
    self.code = code
    self.messages = messages
  }
  
}

// MARK: - 메시지 구조 (에러 케이스 전용)
public struct TokenMessageDTO: Decodable, Equatable {
  public let tokenClass: String
  public let tokenType: String
  public let message: String

  public init(
    tokenClass: String,
    tokenType: String,
    message: String
  ) {
    self.tokenClass = tokenClass
    self.tokenType = tokenType
    self.message = message
  }
  
}
