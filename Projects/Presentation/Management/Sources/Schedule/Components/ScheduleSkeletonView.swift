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
    VStack(spacing: 0) {
      ZStack {
        Color.basicBlack

        VStack(alignment: .leading, spacing: 0) {
          titleSkeleton

          // 스케줄 리스트 skeleton
          ScrollView(.vertical) {
            LazyVStack(spacing: 16) {
              // 스크린샷과 동일한 5개 카드
              ForEach(0..<5, id: \.self) { _ in
                cardSkeleton
              }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
          }
          .scrollIndicators(.hidden)
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .background(Color.basicBlack)
    .onAppear {
      isShimmering = true
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
        .frame(width: 90, height: 22)
        .overlay(shimmerEffect(delay: 0.0))
      Spacer()
    }
    .padding(.horizontal, 20)
    .padding(.top, 24)
    .padding(.bottom, 20)
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
