//
//  ToastManager.swift
//  DesignSystem
//
//  Created by Wonji Suh  on 12/29/25.
//

import SwiftUI
import Combine

@MainActor
public class ToastManager: ObservableObject {
  public static let shared = ToastManager()

  @Published public var currentToast: ToastType?
  @Published public var isVisible = false

  private var dismissTimer: Timer?

  private init() {}

  public func showToast(
    _ toast: ToastType,
    duration: TimeInterval? = 3.0
  ) {
    // 기존 타이머 취소
    dismissTimer?.invalidate()

    // 새 토스트 표시
    currentToast = toast
    withAnimation(.easeOut(duration: 0.3)) {
      isVisible = true
    }

    // 자동 dismiss 타이머 설정
    if let duration {
      dismissTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
        Task { @MainActor in
          self.hideToast()
        }
      }
    } else {
      dismissTimer = nil
    }
  }

  public func hideToast() {
    withAnimation(.easeIn(duration: 0.3)) {
      isVisible = false
    }

    // 애니메이션 완료 후 토스트 제거 (메인 스레드 블로킹 방지)
    Task { @MainActor in
      try? await Task.sleep(for: .seconds(0.3))
      self.currentToast = nil
    }

    dismissTimer?.invalidate()
    dismissTimer = nil
  }

  // 편의 메소드들
  public func showSuccess(_ message: String) {
    showToast(.success(message))
  }

  public func showError(_ message: String) {
    showToast(.error(message))
  }

  public func showWarning(_ message: String) {
    showToast(.warning(message))
  }
  
  public func showInfo(_ message: String) {
    showToast(.info(message))
  }

  public func showLoading(_ message: String) {
    showToast(.loading(message), duration: nil)
  }
}
