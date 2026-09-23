//
//  ScheduleModalSkeletonView.swift
//  Presentation
//
//  Created by DDD on 1/10/26.
//

import SwiftUI

import DDDDesignKit

public struct ScheduleModalSkeletonView: View {
  // 이 모달은 흰 배경(.staticWhite) 위에 올라가므로 밝은 표면용 색 쌍을 쓴다.
  private let base: Color = .gray200
  private let highlight: Color = .gray40

  public init() {}

  public var body: some View {
    VStack(spacing: 24) {
      // Top title - small centered block
      topTitleSkeleton
        .padding(.top, 24)

      // Single text line - left aligned
      singleTextLineSkeleton

      // Large card blocks
      largeCardsSkeleton

      // Bottom Button
      buttonSkeleton

      Spacer()
    }
    .padding(.horizontal, 20)
    .background(.staticWhite)
  }

  // MARK: - Top Title Skeleton
  private var topTitleSkeleton: some View {
    HStack {
      Spacer()
      SkeletonView(.round(cornerRadius: DDDSize.radiusSm), base: base, highlight: highlight)
        .frame(width: 60, height: 4)
      Spacer()
    }
  }

  // MARK: - Single Text Line Skeleton
  private var singleTextLineSkeleton: some View {
    HStack {
      Spacer()
      SkeletonView(.round(cornerRadius: DDDSize.radiusSm), base: base, highlight: highlight)
        .frame(width: 120, height: 30)
      Spacer()
    }
  }

  // MARK: - Large Cards Skeleton
  private var largeCardsSkeleton: some View {
    VStack(spacing: 16) {
      ForEach(0..<4, id: \.self) { index in
        cardSkeleton(index: index)
      }
    }
  }

  @ViewBuilder
  private func cardSkeleton(index: Int) -> some View {
    if index == 3 {
      SkeletonView(.round(cornerRadius: DDDSize.radiusXl), base: base, highlight: highlight)
        .frame(maxWidth: .infinity)
        .frame(height: 40) // 일부만 보이도록
        .clipped()
    } else {
      SkeletonView(.round(cornerRadius: DDDSize.radiusXl), base: base, highlight: highlight)
        .frame(height: 86)
        .frame(maxWidth: .infinity)
    }
  }

  // MARK: - Button Skeleton
  private var buttonSkeleton: some View {
    // 25pt 는 반경 토큰에 없는 값이라 픽셀 유지를 위해 리터럴을 그대로 둔다.
    SkeletonView(.round(cornerRadius: 25), base: base, highlight: highlight)
      .frame(height: 50)
      .frame(maxWidth: .infinity)
  }
}

#Preview {
  ScheduleModalSkeletonView()
    .frame(height: 700)
    .background(Color.gray.opacity(0.1))
}
