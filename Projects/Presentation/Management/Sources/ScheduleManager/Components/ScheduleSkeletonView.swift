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
        Color.staticBlack
          .ignoresSafeArea()

        VStack(alignment: .leading, spacing: 0) {

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
    }
    .background(Color.black)
  }

  // MARK: - Header Skeleton
  private var headerSkeleton: some View {
    HStack {
      // 왼쪽 제목 skeleton
      HStack(spacing: 8) {
        RoundedRectangle(cornerRadius: 6)
          .fill(Color.gray.opacity(0.3))
          .frame(width: 60, height: 24)
          .overlay(shimmerEffect)

        RoundedRectangle(cornerRadius: 4)
          .fill(Color.gray.opacity(0.2))
          .frame(width: 16, height: 16)
          .overlay(shimmerEffect)
      }

      Spacer()

      // 오른쪽 아이콘들 skeleton
      HStack(spacing: 16) {
        // QR 코드 아이콘 skeleton
        Circle()
          .fill(Color.gray.opacity(0.3))
          .frame(width: 44, height: 44)
          .overlay(shimmerEffect)

        // 프로필 아이콘 skeleton
        Circle()
          .fill(Color.gray.opacity(0.2))
          .frame(width: 44, height: 44)
          .overlay(shimmerEffect)
      }
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 12)
  }

  // MARK: - Card Skeleton
  private var cardSkeleton: some View {
    HStack(spacing: 16) {
      // 왼쪽 날짜 박스 skeleton
      RoundedRectangle(cornerRadius: 12)
        .fill(Color.gray.opacity(0.3))
        .frame(width: 60, height: 60)
        .overlay(shimmerEffect)

      // 오른쪽 콘텐츠 skeleton
      VStack(alignment: .leading, spacing: 8) {
        // 제목 skeleton
        RoundedRectangle(cornerRadius: 6)
          .fill(Color.gray.opacity(0.3))
          .frame(height: 20)
          .frame(maxWidth: .infinity, alignment: .leading)
          .overlay(shimmerEffect)

        // 설명 skeleton
        VStack(spacing: 4) {
          RoundedRectangle(cornerRadius: 4)
            .fill(Color.gray.opacity(0.2))
            .frame(height: 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(shimmerEffect)

          RoundedRectangle(cornerRadius: 4)
            .fill(Color.gray.opacity(0.2))
            .frame(height: 14)
            .frame(width: 200, alignment: .leading)
            .overlay(shimmerEffect)
        }
      }

      Spacer()
    }
    .padding(16)
    .background(Color.gray.opacity(0.15))
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }

  // MARK: - Shimmer Effect
  private var shimmerEffect: some View {
    LinearGradient(
      colors: [
        Color.clear,
        Color.white.opacity(0.3),
        Color.clear
      ],
      startPoint: .leading,
      endPoint: .trailing
    )
    .scaleEffect(x: isShimmering ? 3 : 0)
    .offset(x: isShimmering ? 100 : -100)
    .onAppear {
      withAnimation(
        Animation.linear(duration: 2)
          .repeatForever(autoreverses: false)
      ) {
        isShimmering = true
      }
    }
  }
}

#Preview {
  ScheduleSkeletonView()
    .preferredColorScheme(.dark)
}
