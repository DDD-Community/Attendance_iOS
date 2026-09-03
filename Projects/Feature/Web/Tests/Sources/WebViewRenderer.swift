//
//  WebViewRenderer.swift
//  WebTests
//
//  SwiftUI 뷰의 body 를 실제로 평가시켜 렌더링 경로를 커버리지에 태우는 테스트 전용 헬퍼.
//  구현 코드는 건드리지 않고, 테스트 쪽에서만 사용한다.
//

import SwiftUI
import UIKit

@MainActor
enum WebViewRenderer {
  /// UIWindow 에 붙여 body 평가와 UIViewRepresentable 의 makeUIView 를 강제로 실행시킨다.
  /// 네트워크 로딩 완료를 기다리지 않는다.
  static func render(
    _ view: some View,
    size: CGSize = CGSize(width: 393, height: 852)
  ) {
    let controller = UIHostingController(rootView: view)
    let window = UIWindow(frame: CGRect(origin: .zero, size: size))
    window.rootViewController = controller
    window.isHidden = false

    controller.view.frame = CGRect(origin: .zero, size: size)
    controller.view.setNeedsLayout()
    controller.view.layoutIfNeeded()
    window.layoutIfNeeded()
  }

  /// 같은 타입의 뷰를 한 번 렌더링한 뒤 rootView 를 교체해
  /// `updateUIView(_:context:)` 경로까지 태운다.
  static func renderThenUpdate<V: View>(
    _ view: V,
    then next: V,
    size: CGSize = CGSize(width: 393, height: 852)
  ) {
    let controller = UIHostingController(rootView: view)
    let window = UIWindow(frame: CGRect(origin: .zero, size: size))
    window.rootViewController = controller
    window.isHidden = false

    controller.view.frame = CGRect(origin: .zero, size: size)
    controller.view.setNeedsLayout()
    controller.view.layoutIfNeeded()
    window.layoutIfNeeded()

    controller.rootView = next
    controller.view.setNeedsLayout()
    controller.view.layoutIfNeeded()
    window.layoutIfNeeded()
  }
}
