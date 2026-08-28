//
//  ScheduleSkeletonView.swift
//  Presentation
//
//  Created by Wonji Suh  on 1/10/26.
//

import SwiftUI
import DDDDesignKit

public struct ScheduleSkeletonView: View {
  @State private var isAnimating = false

  public init() {}

  public var body: some View {
    ZStack {
      Color.basicBlack

      ScrollView(.vertical) {
        VStack(alignment: .leading, spacing: 14) {
          headerSkeleton
          titleSkeleton
          listSkeleton
        }
        .padding(.horizontal, 24)
        .padding(.top, 10)
        .padding(.bottom, 28)
      }
      .scrollIndicators(.hidden)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.basicBlack)
    .onAppear {
      // 효율적인 반복 제한 애니메이션 (CPU/배터리 최적화)
      withAnimation(.easeInOut(duration: 1.2).repeatCount(8, autoreverses: true)) {
        isAnimating = true
      }

      // 8초 후 애니메이션 자동 종료 (메모리 효율성)
      Task {
        try? await Task.sleep(for: .seconds(10))
        withAnimation(.easeOut(duration: 0.3)) {
          isAnimating = false
        }
      }
    }
  }

  private var headerSkeleton: some View {
    HStack {
      RoundedRectangle(cornerRadius: 12)
        .fill(primarySkeletonFill)
        .frame(width: 56, height: 20)

      Spacer()

      Circle()
        .fill(primarySkeletonFill)
        .frame(width: 28, height: 28)
    }
  }

  // MARK: - Card Skeleton
  private var cardSkeleton: some View {
    HStack(spacing: 16) {
      // 왼쪽 날짜 박스 skeleton
      RoundedRectangle(cornerRadius: 12)
        .fill(primarySkeletonFill)
        .frame(width: 60, height: 60)

      // 오른쪽 콘텐츠 skeleton
      VStack(alignment: .leading, spacing: 8) {
        // 제목 skeleton
        RoundedRectangle(cornerRadius: 6)
          .fill(primarySkeletonFill)
          .frame(height: 20)
          .frame(maxWidth: .infinity, alignment: .leading)

        // 설명 skeleton
        VStack(spacing: 4) {
          RoundedRectangle(cornerRadius: 4)
            .fill(secondarySkeletonFill)
            .frame(height: 14)
            .frame(maxWidth: .infinity, alignment: .leading)

          RoundedRectangle(cornerRadius: 4)
            .fill(secondarySkeletonFill)
            .frame(height: 14)
            .frame(width: 200, alignment: .leading)
        }
      }

      Spacer()
    }
    .padding(16)
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(secondarySkeletonFill)
    )
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }

  // MARK: - Title Skeleton
  private var titleSkeleton: some View {
    HStack {
      RoundedRectangle(cornerRadius: 6)
        .fill(primarySkeletonFill)
        .frame(width: 120, height: 20)
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

  private var primarySkeletonFill: LinearGradient {
    let base = Color.gray90.opacity(isAnimating ? 0.35 : 0.7)
    let tint = Color.blue20.opacity(isAnimating ? 0.12 : 0.22)
    return LinearGradient(
      colors: [base, tint, base],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
  }

  private var secondarySkeletonFill: LinearGradient {
    let base = Color.gray90.opacity(isAnimating ? 0.25 : 0.55)
    let tint = Color.blue20.opacity(isAnimating ? 0.08 : 0.16)
    return LinearGradient(
      colors: [base, tint, base],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
  }
}

#Preview {
  ScheduleSkeletonView()
    .preferredColorScheme(.dark)
}
