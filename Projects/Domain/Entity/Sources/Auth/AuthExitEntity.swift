//
//  AuthExitEntity.swift
//  Entity
//
//  Created by Wonji Suh  on 1/4/26.
//

import  Foundation

public struct AuthExitEntity: Equatable {
  public let code: String?
  public let message: String?
  public let detail: String?

  public init(
    code: String? = nil,
    message: String? = nil,
    detail: String? = nil
  ) {
    self.code = code
    self.message = message
    self.detail = detail
  }
}

// MARK: - Mock Data
public extension AuthExitEntity {
  static func mockSuccessData() -> AuthExitEntity {
    return AuthExitEntity(
      code: "200",
      message: "로그아웃이 성공적으로 처리되었습니다.",
      detail: nil
    )
  }

  static func mockFailureData() -> AuthExitEntity {
    return AuthExitEntity(
      code: "500",
      message: "로그아웃 처리 중 오류가 발생했습니다.",
      detail: "서버와 연결을 확인해주세요."
    )
  }

  static func mockTokenExpiredData() -> AuthExitEntity {
    return AuthExitEntity(
      code: "401",
      message: "토큰이 만료되었습니다.",
      detail: "다시 로그인해주세요."
    )
  }
}
