//
//  EditAttendance.swift
//  Entity
//
//  Created by Wonji Suh  on 1/13/26.
//

import Foundation

public struct EditAttendance: Equatable {
  public let isSuccess: Bool
  public let code: String?
  public let message: String?
  public let detail: String?

  public init(
    isSuccess: Bool,
    code: String? = nil,
    message: String? = nil,
    detail: String? = nil,
  ) {
    self.isSuccess = isSuccess
    self.code = code
    self.message = message
    self.detail = detail

  }
}

// MARK: - Mock Data
public extension EditAttendance {
  static func mockSuccessData() -> EditAttendance {
    return EditAttendance(
      isSuccess: true,
      code: "200",
      message: "출석 상태가 성공적으로 변경되었습니다.",
      detail: nil
    )
  }

  static func mockFailureData() -> EditAttendance {
    return EditAttendance(
      isSuccess: false,
      code: "400",
      message: "출석 상태 변경에 실패했습니다.",
      detail: "유효하지 않은 참석 ID입니다."
    )
  }

  static func mockNetworkErrorData() -> EditAttendance {
    return EditAttendance(
      isSuccess: false,
      code: "500",
      message: "서버 오류가 발생했습니다.",
      detail: "네트워크 연결을 확인해주세요."
    )
  }
}

