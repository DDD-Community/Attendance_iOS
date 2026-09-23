//
//  ManagementSupportViewRenderer.swift
//  ManagementTests
//
//  SwiftUI 뷰를 실제로 레이아웃시켜 body 실행 커버리지를 확보하는 헬퍼.
//

import SwiftUI
import UIKit

@MainActor
enum ManagementSupportViewRenderer {
  static func render<V: View>(
    _ view: V,
    size: CGSize = CGSize(width: 393, height: 852)
  ) {
    let controller = UIHostingController(rootView: view)
    controller.view.frame = CGRect(origin: .zero, size: size)
    controller.view.setNeedsLayout()
    controller.view.layoutIfNeeded()
  }
}
