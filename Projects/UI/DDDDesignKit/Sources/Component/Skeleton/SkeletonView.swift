//
//  SkeletonView.swift
//  DDDDesignKit
//
//  Copyright © 2026 DDD. All rights reserved.
//

import SwiftUI

/// 로딩 중 콘텐츠 자리를 대신 채우는 시머 자리표시자.
public struct SkeletonView: View {
  private let shape: SkeletonShape
  private let baseColor: Color
  private let highlightColor: Color

  /// 기본값은 다크 배경 기준이다. 흰 배경 모달처럼 밝은 표면에서는
  /// `base: .gray200, highlight: .gray40` 처럼 밝은 쌍을 넘긴다.
  public init(
    _ shape: SkeletonShape,
    base: Color = .gray80,
    highlight: Color = .gray60
  ) {
    self.shape = shape
    self.baseColor = base
    self.highlightColor = highlight
  }

  public var body: some View {
    shape
      .fill(baseColor)
      .overlay {
        GeometryReader {
          let size = $0.size
          let skeletonWidth = size.width / 2

          let blurRadius = max(skeletonWidth / 2, 30)
          let blurDiameter = blurRadius * 2

          let minX = -(skeletonWidth + blurDiameter)
          let maxX = size.width + skeletonWidth + blurDiameter

          TimelineView(.animation) { timeline in
            Rectangle()
              .fill(highlightColor)
              .frame(width: skeletonWidth, height: size.height * 2)
              .frame(height: size.height)
              .blur(radius: blurRadius)
              .rotationEffect(.init(degrees: rotation))
              .blendMode(.softLight)
              .offset(x: minX + (maxX - minX) * phase(at: timeline.date))
          }
        }
      }
      .clipShape(shape)
      .compositingGroup()
      .accessibilityIdentifier("skeleton_root")
  }

  private var rotation: Double {
    return 5
  }

  private var period: Double {
    return 1
  }

  private func phase(at date: Date) -> Double {
    date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: period) / period
  }
}

// MARK: - Preview

#Preview {
  @Previewable
  @State var isLoading = true

  VStack(spacing: 10) {
    Text("안녕하세요")
      .skeleton(
        isLoading: isLoading,
        shape: .round(),
        width: 200,
        height: 100
      )
      .onTapGesture {
        isLoading.toggle()
      }

    Button("토글") {
      isLoading.toggle()
    }
  }
}
