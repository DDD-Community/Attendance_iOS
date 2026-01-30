//
//  WithdrawEntity.swift
//  Entity
//
//  Created by Wonji Suh  on 1/2/26.
//

import Foundation

public struct WithdrawEntity: Equatable {
  public let isSuccess: Bool
  public let code: String?
  public let message: String?
  public let detail: String?

  public init(
    isSuccess: Bool,
    code: String? = nil,
    message: String? = nil,
    detail: String? = nil
  ) {
    self.isSuccess = isSuccess
    self.code = code
    self.message = message
    self.detail = detail
  }
}

// MARK: - Mock Data
public extension WithdrawEntity {
  static func mockSuccessData() -> WithdrawEntity {
    return WithdrawEntity(
      isSuccess: true,
      code: "200",
      message: "회원 탈퇴가 성공적으로 처리되었습니다.",
      detail: nil
    )
  }

  static func mockFailureData() -> WithdrawEntity {
    return WithdrawEntity(
      isSuccess: false,
      code: "400",
      message: "회원 탈퇴 처리에 실패했습니다.",
      detail: "유효하지 않은 사용자 정보입니다."
    )
  }

  static func mockUnauthorizedData() -> WithdrawEntity {
    return WithdrawEntity(
      isSuccess: false,
      code: "401",
      message: "인증이 필요합니다.",
      detail: "로그인 후 다시 시도해주세요."
    )
  }
}
