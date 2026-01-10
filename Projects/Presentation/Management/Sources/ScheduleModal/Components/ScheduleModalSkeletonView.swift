//
//  ScheduleModalSkeletonView.swift
//  Presentation
//
//  Created by Wonji Suh  on 1/10/26.
//

import SwiftUI
import DesignSystem

public struct ScheduleModalSkeletonView: View {
  @State private var isShimmering = false

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

      Spacer()

      // Bottom Button
      buttonSkeleton
        .padding(.bottom, 34)
    }
    .padding(.horizontal, 20)
    .background(.staticWhite)
    .onAppear {
      isShimmering = true
    }
  }

  // MARK: - Top Title Skeleton
  private var topTitleSkeleton: some View {
    HStack {
      Spacer()
      RoundedRectangle(cornerRadius: 6)
        .fill(.gray.opacity(0.3))
        .frame(width: 60, height: 4)
        .overlay(shimmerEffect(delay: 0.0))
      Spacer()
    }
  }

  // MARK: - Single Text Line Skeleton
  private var singleTextLineSkeleton: some View {
    HStack {
      Spacer()
      RoundedRectangle(cornerRadius: 6)
        .fill(.gray.opacity(0.3))
        .frame(width: 120, height: 30)
        .overlay(shimmerEffect(delay: 0.2))
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
      RoundedRectangle(cornerRadius: 16)
        .fill(.gray.opacity(0.15))
        .frame(height: 86)
        .frame(maxWidth: .infinity)
        .overlay(
          shimmerEffect(delay: 0.4 + Double(index) * 0.2)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        )
        .clipped()
        .frame(height: 40) // 일부만 보이도록
    } else {
      RoundedRectangle(cornerRadius: 16)
        .fill(.gray.opacity(0.15))
        .frame(height: 86)
        .frame(maxWidth: .infinity)
        .overlay(
          shimmerEffect(delay: 0.4 + Double(index) * 0.2)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        )
    }
  }

  // MARK: - Button Skeleton
  private var buttonSkeleton: some View {
    RoundedRectangle(cornerRadius: 25)
      .fill(.blue20)
      .frame(height: 50)
      .frame(maxWidth: .infinity)
      .overlay(
        shimmerEffect(delay: 1.0)
          .clipShape(RoundedRectangle(cornerRadius: 25))
      )
  }

  // MARK: - Shimmer Effect
  private func shimmerEffect(delay: Double) -> some View {
    GeometryReader { proxy in
      LinearGradient(
        colors: [
          Color.clear,
          Color.white.opacity(0.25),
          Color.clear
        ],
        startPoint: .leading,
        endPoint: .trailing
      )
      .frame(width: proxy.size.width * 0.5, height: proxy.size.height)
      .offset(x: isShimmering ? proxy.size.width * 0.5 - 20 : 0)
      .blendMode(.screen)
      .allowsHitTesting(false)
      .animation(
        Animation.linear(duration: 2.0)
          .delay(delay)
          .repeatForever(autoreverses: false),
        value: isShimmering
      )
    }
  }
}

#Preview {
  ScheduleModalSkeletonView()
    .frame(height: 700)
    .background(Color.gray.opacity(0.1))
}
