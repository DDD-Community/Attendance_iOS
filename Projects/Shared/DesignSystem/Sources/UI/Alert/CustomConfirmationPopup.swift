//
//  CustomConfirmationPopup.swift
//  DesignSystem
//
//  Created by Wonji Suh on 1/4/26.
//

import SwiftUI
import ComposableArchitecture

// MARK: - TCA Compatible Custom Alert

// MARK: - Generic CustomAlertState (TCA 스타일)

@ObservableState
public struct CustomAlertState<Action>: Equatable {
  public let title: String
  public let message: String
  public let confirmTitle: String
  public let cancelTitle: String
  public let isDestructive: Bool

  public init(
    title: String,
    message: String = "",
    confirmTitle: String = "확인",
    cancelTitle: String = "취소",
    isDestructive: Bool = false
  ) {
    self.title = title
    self.message = message
    self.confirmTitle = confirmTitle
    self.cancelTitle = cancelTitle
    self.isDestructive = isDestructive
  }
}

@CasePathable
public enum CustomAlertAction: Equatable {
  case confirmTapped
  case cancelTapped
}

// TCA Reducer (필요한 경우)
@Reducer
public struct CustomConfirmAlert {
  public init() {}

  public var body: some Reducer<CustomAlertState<CustomAlertAction>, CustomAlertAction> {
    EmptyReducer()
  }
}

public extension CustomAlertState where Action == CustomAlertAction {
  /// TCA AlertState 스타일 builder
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
      isDestructive: isDestructive
    )
  }

  /// 계정 탈퇴 확인 CustomAlertState
  static func withdrawAccount() -> CustomAlertState<CustomAlertAction> {
    .alert(
      title: "정말 탈퇴하시겠습니까?",
      message: "탈퇴 시, 등록된 모든 출석 데이터가 삭제됩니다.",
      confirmTitle: "탈퇴하기",
      cancelTitle: "취소",
      isDestructive: true
    )
  }

  /// 로그아웃 확인 CustomAlertState
  static func logout() -> CustomAlertState<CustomAlertAction> {
    .alert(
      title: "로그아웃 하시겠습니까?",
      message: "다시 로그인해야 앱을 사용할 수 있습니다.",
      confirmTitle: "로그아웃",
      cancelTitle: "취소",
      isDestructive: false
    )
  }
}

public extension View {
  /// 확인/취소 팝업을 띄우는 Modifier (Item 기반)
  ///
  /// - Parameters:
  ///   - item: AlertItem? - 팝업 설정이 담긴 아이템 (nil이면 팝업 숨김)
  func customConfirmationPopup(
    item: AlertItem?
  ) -> some View {
    self.modifier(
      CustomConfirmationPopupItemModifier(item: item)
    )
  }

  /// TCA 스타일 CustomAlert 팝업 (reducer에서 액션 처리)
  ///
  /// - Parameter store: TCA Store scope for CustomAlert
  func customAlert(
    _ store: Binding<Store<CustomAlertState<CustomAlertAction>, CustomAlertAction>?>
  ) -> some View {
    self.overlay {
      if let alertStore = store.wrappedValue {
        let alertState = alertStore.withState { $0 }
        CustomConfirmationPopup(
          title: alertState.title,
          message: alertState.message,
          confirmTitle: alertState.confirmTitle,
          cancelTitle: alertState.cancelTitle,
          isDestructive: alertState.isDestructive,
          onConfirm: {
            alertStore.send(.confirmTapped)
          },
          onCancel: {
            alertStore.send(.cancelTapped)
          }
        )
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.easeInOut(duration: 0.3), value: alertState.title.isEmpty == false)
      }
    }
  }

  /// 확인/취소 팝업을 띄우는 Modifier (개별 파라미터)
  ///
  /// - Parameters:
  ///   - isPresented: 팝업 표시 여부
  ///   - title: 제목
  ///   - message: 메시지
  ///   - confirmTitle: 확인 버튼 텍스트 (기본: "확인")
  ///   - cancelTitle: 취소 버튼 텍스트 (기본: "취소")
  ///   - isDestructive: 확인 버튼이 위험한 액션인지 여부 (기본: false)
  ///   - onConfirm: 확인 버튼 터치 시 액션
  ///   - onCancel: 취소 버튼 터치 시 액션
  func customConfirmationPopup(
    isPresented: Bool,
    title: String,
    message: String,
    confirmTitle: String = "확인",
    cancelTitle: String = "취소",
    isDestructive: Bool = false,
    onConfirm: @escaping () -> Void,
    onCancel: @escaping () -> Void
  ) -> some View {
    self.modifier(
      CustomConfirmationPopupModifier(
        isPresented: isPresented,
        title: title,
        message: message,
        confirmTitle: confirmTitle,
        cancelTitle: cancelTitle,
        isDestructive: isDestructive,
        onConfirm: onConfirm,
        onCancel: onCancel
      )
    )
  }
}

// MARK: - Item-based Modifier

struct CustomConfirmationPopupItemModifier: ViewModifier {
  private let item: AlertItem?

  init(item: AlertItem?) {
    self.item = item
  }

  func body(content: Content) -> some View {
    content
      .overlay {
        if let item = item {
          CustomConfirmationPopup(
            title: item.title,
            message: item.message,
            confirmTitle: item.confirmTitle,
            cancelTitle: item.cancelTitle,
            isDestructive: item.isDestructive,
            onConfirm: item.onConfirm,
            onCancel: item.onCancel
          )
          .transition(.move(edge: .bottom).combined(with: .opacity))
          .animation(.easeInOut(duration: 0.3), value: true)
        }
      }
  }
}


// MARK: - Parameter-based Modifier

struct CustomConfirmationPopupModifier: ViewModifier {
  private let isPresented: Bool
  private let title: String
  private let message: String
  private let confirmTitle: String
  private let cancelTitle: String
  private let isDestructive: Bool
  private let onConfirm: () -> Void
  private let onCancel: () -> Void

  init(
    isPresented: Bool,
    title: String,
    message: String,
    confirmTitle: String,
    cancelTitle: String,
    isDestructive: Bool,
    onConfirm: @escaping () -> Void,
    onCancel: @escaping () -> Void
  ) {
    self.isPresented = isPresented
    self.title = title
    self.message = message
    self.confirmTitle = confirmTitle
    self.cancelTitle = cancelTitle
    self.isDestructive = isDestructive
    self.onConfirm = onConfirm
    self.onCancel = onCancel
  }

  func body(content: Content) -> some View {
    content
      .overlay {
        if isPresented {
          CustomConfirmationPopup(
            title: title,
            message: message,
            confirmTitle: confirmTitle,
            cancelTitle: cancelTitle,
            isDestructive: isDestructive,
            onConfirm: onConfirm,
            onCancel: onCancel
          )
          .transition(.move(edge: .bottom).combined(with: .opacity))
          .animation(.easeInOut(duration: 0.3), value: isPresented)
        }
      }
  }
}

struct CustomConfirmationPopup: View {
  private let title: String
  private let message: String
  private let confirmTitle: String
  private let cancelTitle: String
  private let isDestructive: Bool
  private let onConfirm: () -> Void
  private let onCancel: () -> Void

  init(
    title: String,
    message: String,
    confirmTitle: String,
    cancelTitle: String,
    isDestructive: Bool,
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

  var body: some View {
    ZStack {
      // Dark overlay background
      Color.black
        .opacity(0.6)
        .edgesIgnoringSafeArea(.all)
        .onTapGesture {
          onCancel()
        }

      VStack(alignment: .center, spacing: 24) {
        // Title and Message
        VStack(alignment: .center, spacing: 8) {
          Text(title)
            .pretendardCustomFont(textStyle: .title3NormalBold)
            .foregroundStyle(.staticWhite)
            .multilineTextAlignment(.center)

          if !message.isEmpty {
            Text(message)
              .pretendardCustomFont(textStyle: .body3NormalRegular)
              .foregroundStyle(.textSecondary)
              .multilineTextAlignment(.center)
          }
        }

        // Button Stack
        HStack(spacing: 12) {
          // Confirm Button (Left)
          Button {
            onConfirm()
          } label: {
            Text(confirmTitle)
              .pretendardFont(family: .Medium, size: 16)
              .foregroundStyle(.staticWhite)
              .frame(maxWidth: .infinity)
              .frame(height: 48)
          }
          .background(.gray80)
          .clipShape(.rect(cornerRadius: 20))
          .contentShape(.rect(cornerRadius: 20))

          // Cancel Button (Right)
          Button {
            onCancel()
          } label: {
            Text(cancelTitle)
              .pretendardFont(family: .Medium, size: 16)
              .foregroundStyle(.staticWhite)
              .frame(maxWidth: .infinity)
              .frame(height: 48)
          }
          .background(.blue40)
          .clipShape(.rect(cornerRadius: 20))
          .contentShape(.rect(cornerRadius: 20))
        }
      }
      .padding(.vertical, 32)
      .padding(.horizontal, 24)
      .frame(width: 320)
      .background(.gray90)
      .clipShape(.rect(cornerRadius: 20))
      .onTapGesture {
        // Prevent background tap when tapping on popup content
      }
    }
  }
}

// MARK: - Color Extension for Hex

#Preview("Item Based") {
  VStack {
    Text("Background Content")
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(.gray.opacity(0.2))
  }
  .customConfirmationPopup(
    item: .withdrawAccount(
      onConfirm: {
        print("탈퇴하기 선택")
      },
      onCancel: {
        print("취소 선택")
      }
    )
  )
}

#Preview("Parameter Based") {
  VStack {
    Text("Background Content")
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(.gray.opacity(0.2))
  }
  .customConfirmationPopup(
    isPresented: true,
    title: "정말 탈퇴하시겠습니까?",
    message: "탈퇴 시, 등록된 모든 출석 데이터가 삭제됩니다.",
    confirmTitle: "탈퇴하기",
    cancelTitle: "취소",
    isDestructive: true,
    onConfirm: {
      print("탈퇴하기 선택")
    },
    onCancel: {
      print("취소 선택")
    }
  )
}
