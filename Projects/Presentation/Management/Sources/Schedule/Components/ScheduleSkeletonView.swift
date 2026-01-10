//
//  ScheduleSkeletonView.swift
//  Presentation
//
//  Created by Wonji Suh  on 1/10/26.
//

import SwiftUI
import DesignSystem

public struct ScheduleSkeletonView: View {
  @State private var isShimmering = false

  public init() {}

  public var body: some View {
    ZStack {
      Color.basicBlack

      ScrollView(.vertical) {
        VStack(alignment: .leading, spacing: 16) {
          headerSkeleton
          titleSkeleton
          listSkeleton
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 32)
      }
      .scrollIndicators(.hidden)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.basicBlack)
    .onAppear {
      isShimmering = true
    }
  }

  private var headerSkeleton: some View {
    HStack {
      RoundedRectangle(cornerRadius: 12)
        .fill(Color.gray.opacity(0.3))
        .frame(width: 56, height: 20)
        .overlay(shimmerEffect(delay: 0.0))

      Spacer()

      Circle()
        .fill(Color.gray.opacity(0.3))
        .frame(width: 28, height: 28)
        .overlay(shimmerEffect(delay: 0.1))
    }
  }

  // MARK: - Card Skeleton
  private var cardSkeleton: some View {
    HStack(spacing: 16) {
      // 왼쪽 날짜 박스 skeleton
      RoundedRectangle(cornerRadius: 12)
        .fill(Color.gray.opacity(0.3))
        .frame(width: 60, height: 60)

      // 오른쪽 콘텐츠 skeleton
      VStack(alignment: .leading, spacing: 8) {
        // 제목 skeleton
        RoundedRectangle(cornerRadius: 6)
          .fill(Color.gray.opacity(0.3))
          .frame(height: 20)
          .frame(maxWidth: .infinity, alignment: .leading)
          .overlay(shimmerEffect(delay: 0.0))

        // 설명 skeleton
        VStack(spacing: 4) {
          RoundedRectangle(cornerRadius: 4)
            .fill(Color.gray.opacity(0.2))
            .frame(height: 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(shimmerEffect(delay: 0.3))

          RoundedRectangle(cornerRadius: 4)
            .fill(Color.gray.opacity(0.2))
            .frame(height: 14)
            .frame(width: 200, alignment: .leading)
            .overlay(shimmerEffect(delay: 0.6))
        }
      }

      Spacer()
    }
    .padding(16)
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(Color.gray.opacity(0.15))
    )
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }

  // MARK: - Title Skeleton
  private var titleSkeleton: some View {
    HStack {
      RoundedRectangle(cornerRadius: 6)
        .fill(Color.gray.opacity(0.3))
        .frame(width: 120, height: 20)
        .overlay(shimmerEffect(delay: 0.0))
      Spacer()
    }
  }

  private var listSkeleton: some View {
    LazyVStack(spacing: 16) {
      ForEach(0..<5, id: \.self) { _ in
        cardSkeleton
      }
    }
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
  ScheduleSkeletonView()
    .preferredColorScheme(.dark)
}
