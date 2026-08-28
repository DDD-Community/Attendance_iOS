//
//  ToastView.swift
//  DDDDesignKit
//
//  Created by DDD on 12/29/25.
//

import SwiftUI

public struct ToastView: View {
  let toast: ToastType

  public init(toast: ToastType) {
    self.toast = toast
  }

  public var body: some View {
    HStack(alignment: .center, spacing: 8) {
      leadingView

      // 메시지
      Text(toast.message)
        .pretendardCustomFont(textStyle: .body1NormalBold)
        .foregroundColor(.white)
        .multilineTextAlignment(.leading)
        .fixedSize(horizontal: false, vertical: true)
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 11)
    .background(toast.backgroundColor)
    .cornerRadius(12)
    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
  }
}

// MARK: - Toast Overlay Modifier
public struct ToastOverlay: ViewModifier {
  @ObservedObject private var toastManager = ToastManager.shared
  let position: ToastPosition
  let horizontalPadding: CGFloat
  let topPadding: CGFloat
  let bottomPadding: CGFloat

  public init(
    position: ToastPosition = .top,
    horizontalPadding: CGFloat = 20,
    topPadding: CGFloat = 30,
    bottomPadding: CGFloat = 30
  ) {
    self.position = position
    self.horizontalPadding = horizontalPadding
    self.topPadding = topPadding
    self.bottomPadding = bottomPadding
  }

  public func body(content: Content) -> some View {
    content
      .overlay(alignment: position.alignment) {
        if let toast = toastManager.currentToast {
          ToastView(toast: toast)
            .padding(.horizontal, horizontalPadding)
            .padding(.top, position == .top ? topPadding : 0)
            .padding(.bottom, position == .bottom ? bottomPadding : 0)
            .opacity(toastManager.isVisible ? 1 : 0)
            .offset(y: toastManager.isVisible ? 0 : position.hiddenOffsetY)
            .transition(.asymmetric(
              insertion: .move(edge: position.edge).combined(with: .opacity),
              removal: .move(edge: position.edge).combined(with: .opacity)
            ))
            .allowsHitTesting(toastManager.isVisible)
        }
      }
  }
}

public enum ToastPosition: Equatable {
  case top
  case bottom

  var alignment: Alignment {
    switch self {
    case .top:
      return .top
    case .bottom:
      return .bottom
    }
  }

  var edge: Edge {
    switch self {
    case .top:
      return .top
    case .bottom:
      return .bottom
    }
  }

  var hiddenOffsetY: CGFloat {
    switch self {
    case .top:
      return -100
    case .bottom:
      return 100
    }
  }
}

// MARK: - View Extension
public extension View {
  func toastOverlay(
    position: ToastPosition = .top,
    horizontalPadding: CGFloat = 20,
    topPadding: CGFloat = 30,
    bottomPadding: CGFloat = 30
  ) -> some View {
    modifier(
      ToastOverlay(
        position: position,
        horizontalPadding: horizontalPadding,
        topPadding: topPadding,
        bottomPadding: bottomPadding
      )
    )
  }
}

// MARK: - Private views
private extension ToastView {
  @ViewBuilder
  var leadingView: some View {
    switch toast {
      case .loading:
        ProgressView()
          .progressViewStyle(.circular)
          .tint(toast.iconColor)
          .frame(width: 16, height: 16)
      default:
        if let iconName = toast.iconName {
          Image(assetName: iconName)
            .resizable()
            .scaledToFit()
            .frame(width: 12, height: 12)
        }
    }
  }
}

// MARK: - Preview
#Preview {
  VStack(spacing: 20) {
    Button("성공 토스트") {
      ToastManager.shared.showSuccess("로그인에 성공했습니다!")
    }

    Button("에러 토스트") {
      ToastManager.shared.showError("인증에 실패했어요. 다시 시도해주세요..")
    }

    Button("경고 토스트") {
      ToastManager.shared.showWarning("네트워크 연결을 확인해주세요.")
    }

    Button("정보 토스트") {
      ToastManager.shared.showInfo("새로운 업데이트가 있습니다.")
    }
  }
  .padding()
  .toastOverlay()
}
