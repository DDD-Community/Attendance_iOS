//
//  Skeleton+View.swift
//  DDDDesignKit
//
//  Copyright © 2026 DDD. All rights reserved.
//

import SwiftUI

// MARK: - View Extension

public extension View {
  /// 데이터가 오기 전 원본이 비어 크기를 잃는 경우 `width` / `height` 로 자리를 빌려준다.
  /// 로딩 중에만 적용되므로 데이터가 온 뒤의 동적 크기는 방해하지 않는다.
  func skeleton(
    isLoading: Bool,
    shape: SkeletonShape,
    width: CGFloat? = nil,
    height: CGFloat? = nil,
    base: Color = .gray80,
    highlight: Color = .gray60
  ) -> some View {
    modifier(
      SkeletonModifier(
        isLoading: isLoading,
        width: width,
        height: height,
        shape: shape,
        base: base,
        highlight: highlight
      )
    )
  }
}

// MARK: - Modifier

private struct SkeletonModifier: ViewModifier {
  let isLoading: Bool
  let width: CGFloat?
  let height: CGFloat?
  let shape: SkeletonShape
  let base: Color
  let highlight: Color

  func body(content: Content) -> some View {
    ZStack {
      content
        .opacity(isLoading ? 0 : 1)

      if isLoading {
        SkeletonView(shape, base: base, highlight: highlight)
          .frame(
            width: width,
            height: height
          )
          .transition(.opacity)
      }
    }
    .fixedSize(
      horizontal: isLoading && width != nil,
      vertical: isLoading && height != nil
    )
    .animation(.easeInOut(duration: 0.2), value: isLoading)
  }
}
