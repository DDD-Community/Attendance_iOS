//
//  AlertItem.swift
//  DesignSystem
//
//  Created by Wonji Suh on 1/4/26.
//

import SwiftUI

// MARK: - AlertItem

public struct AlertItem: Identifiable, Equatable {
  public let id = UUID()
  public let title: String
  public let message: String
  public let confirmTitle: String
  public let cancelTitle: String
  public let isDestructive: Bool
  public let onConfirm: () -> Void
  public let onCancel: () -> Void

  public static func == (lhs: AlertItem, rhs: AlertItem) -> Bool {
    lhs.id == rhs.id &&
    lhs.title == rhs.title &&
    lhs.message == rhs.message &&
    lhs.confirmTitle == rhs.confirmTitle &&
    lhs.cancelTitle == rhs.cancelTitle &&
    lhs.isDestructive == rhs.isDestructive
  }

  public init(
    title: String,
    message: String,
    confirmTitle: String = "확인",
    cancelTitle: String = "취소",
    isDestructive: Bool = false,
    onConfirm: @escaping () -> Void,
    onCancel: @escaping () -> Void
  ) {
    self.title = title
    self.message = message
    self.confirmTitle = confirmTitle
    self.cancelTitle = cancelTitle
    self.isDestructive = isDestructive
    self.onConfirm = onConfirm
    self.onCancel = onCancel
  }
}

// MARK: - Predefined Alert Items

public extension AlertItem {
  /// 계정 탈퇴 확인 AlertItem
  static func withdrawAccount(
    onConfirm: @escaping () -> Void,
    onCancel: @escaping () -> Void
  ) -> AlertItem {
    AlertItem(
      title: "정말 탈퇴하시겠습니까?",
      message: "탈퇴 시, 등록된 모든 출석 데이터가\n삭제됩니다.",
      confirmTitle: "탈퇴하기",
      cancelTitle: "취소",
      isDestructive: true,
      onConfirm: onConfirm,
      onCancel: onCancel
    )
  }

  /// 데이터 삭제 확인 AlertItem
  static func deleteData(
    dataName: String,
    onConfirm: @escaping () -> Void,
    onCancel: @escaping () -> Void
  ) -> AlertItem {
    AlertItem(
      title: "\(dataName)를 삭제하시겠습니까?",
      message: "삭제된 데이터는 복구할 수 없습니다.",
      confirmTitle: "삭제",
      cancelTitle: "취소",
      isDestructive: true,
      onConfirm: onConfirm,
      onCancel: onCancel
    )
  }

  /// 로그아웃 확인 AlertItem
  static func logout(
    onConfirm: @escaping () -> Void,
    onCancel: @escaping () -> Void
  ) -> AlertItem {
    AlertItem(
      title: "로그아웃 하시겠습니까?",
      message: "",
      confirmTitle: "로그아웃",
      cancelTitle: "취소",
      isDestructive: false,
      onConfirm: onConfirm,
      onCancel: onCancel
    )
  }

  /// 변경사항 저장 확인 AlertItem
  static func saveChanges(
    onConfirm: @escaping () -> Void,
    onCancel: @escaping () -> Void
  ) -> AlertItem {
    AlertItem(
      title: "변경사항을 저장하시겠습니까?",
      message: "저장하지 않으면 변경사항이 사라집니다.",
      confirmTitle: "저장",
      cancelTitle: "취소",
      isDestructive: false,
      onConfirm: onConfirm,
      onCancel: onCancel
    )
  }
}
