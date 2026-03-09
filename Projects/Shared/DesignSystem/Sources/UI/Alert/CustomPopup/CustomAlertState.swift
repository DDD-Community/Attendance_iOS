//
//  CustomAlertState.swift
//  DesignSystem
//
//  Created by Wonji Suh on 1/4/26.
//

import SwiftUI
import ComposableArchitecture

@ObservableState
public struct CustomAlertState<Action>: Equatable {
  public let title: String
  public let message: String
  public let confirmTitle: String
  public let cancelTitle: String
  public let isDestructive: Bool
  public let style: CustomAlertStyle
  public let checkboxTitle: String

  public init(
    title: String,
    message: String = "",
    confirmTitle: String = "확인",
    cancelTitle: String = "취소",
    isDestructive: Bool = false,
    style: CustomAlertStyle = .confirmation,
    checkboxTitle: String = ""
  ) {
    self.title = title
    self.message = message
    self.confirmTitle = confirmTitle
    self.cancelTitle = cancelTitle
    self.isDestructive = isDestructive
    self.style = style
    self.checkboxTitle = checkboxTitle
  }
}

public enum CustomAlertStyle: Equatable {
  case confirmation
  case consent
}

@CasePathable
public enum CustomAlertAction: Equatable {
  case confirmTapped
  case cancelTapped
  case policyTapped
}

@Reducer
public struct CustomConfirmAlert {
  public init() {}

  public var body: some Reducer<CustomAlertState<CustomAlertAction>, CustomAlertAction> {
    EmptyReducer()
  }
}

public extension CustomAlertState where Action == CustomAlertAction {
  static func alert(
    title: String,
    message: String = "",
    confirmTitle: String = "확인",
    cancelTitle: String = "취소",
    isDestructive: Bool = false
  ) -> CustomAlertState<CustomAlertAction> {
    CustomAlertState(
      title: title,
      message: message,
      confirmTitle: confirmTitle,
      cancelTitle: cancelTitle,
      isDestructive: isDestructive,
      style: .confirmation,
      checkboxTitle: ""
    )
  }

  static func withdrawAccount() -> CustomAlertState<CustomAlertAction> {
    .alert(
      title: "정말 탈퇴하시겠습니까?",
      message: "탈퇴 시, 등록된 모든 출석 데이터가 삭제됩니다.",
      confirmTitle: "탈퇴하기",
      cancelTitle: "취소",
      isDestructive: true
    )
  }

  static func logout() -> CustomAlertState<CustomAlertAction> {
    .alert(
      title: "로그아웃 하시겠습니까?",
      message: "다시 로그인해야 앱을 사용할 수 있습니다.",
      confirmTitle: "로그아웃",
      cancelTitle: "취소",
      isDestructive: false
    )
  }

  static func consent(
    title: String,
    message: String,
    checkboxTitle: String
  ) -> CustomAlertState<CustomAlertAction> {
    CustomAlertState(
      title: title,
      message: message,
      confirmTitle: "",
      cancelTitle: "",
      isDestructive: false,
      style: .consent,
      checkboxTitle: checkboxTitle
    )
  }

  static func privacyPolicyConsent() -> CustomAlertState<CustomAlertAction> {
    .consent(
      title: "개인정보처리방침에\n동의하시겠습니까?",
      message: "회원 가입 및 서비스 제공을 위해\n개인정보를 수집·이용합니다.",
      checkboxTitle: "개인정보처리방침 동의"
    )
  }

  static func appUpdate(
    version: String,
    releaseNotes: String? = nil
  ) -> CustomAlertState<CustomAlertAction> {
    let message = if let releaseNotes = releaseNotes, !releaseNotes.isEmpty {
      "새로운 버전 \(version)이 출시되었습니다!\n\n\(releaseNotes)\n\n더 나은 경험을 위해 업데이트하세요!"
    } else {
      "새로운 버전 \(version)이 준비되었습니다!\n\n더 나은 경험을 위해 지금 업데이트하세요!"
    }

    return .alert(
      title: "새로운 버전이 출시되었어요!",
      message: message,
      confirmTitle: "지금 업데이트",
      cancelTitle: "나중에 할게요",
      isDestructive: false
    )
  }
}
