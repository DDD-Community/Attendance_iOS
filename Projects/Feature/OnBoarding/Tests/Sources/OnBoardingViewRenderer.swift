//
//  OnBoardingViewRenderer.swift
//  OnBoardingTests
//
//  SwiftUI View 의 body 를 실제로 평가시키기 위한 최소 렌더 헬퍼.
//  UIHostingController 에 올리고 강제 레이아웃을 돌려 View 코드가 실행되게 한다.
//

import SwiftUI
import UIKit

@MainActor
enum OnBoardingViewRenderer {
  /// iPhone 15 세로 기준 화면 크기
  static let defaultSize = CGSize(width: 393, height: 852)

  /// 전달된 View 를 호스팅 컨트롤러에 올리고 레이아웃까지 강제한다.
  static func render(_ view: some View, size: CGSize = defaultSize) {
    let controller = UIHostingController(rootView: view)
    controller.view.frame = CGRect(origin: .zero, size: size)
    controller.view.setNeedsLayout()
    controller.view.layoutIfNeeded()
  }
}
