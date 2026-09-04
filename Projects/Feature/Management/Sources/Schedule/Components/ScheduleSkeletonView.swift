//
//  ScheduleSkeletonView.swift
//  Presentation
//
//  Created by DDD on 1/10/26.
//

import SwiftUI

import DDDDesignKit

public struct ScheduleSkeletonView: View {
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
  }

  // MARK: - Header Skeleton

  private var headerSkeleton: some View {
    HStack {
      SkeletonView(.round(cornerRadius: DDDSize.radiusLg))
        .frame(width: 56, height: 20)

      Spacer()

      SkeletonView(.circle)
        .frame(width: 28, height: 28)
    }
  }

  // MARK: - Title Skeleton

  private var titleSkeleton: some View {
    HStack {
      SkeletonView(.round(cornerRadius: DDDSize.radiusSm))
        .frame(width: 120, height: 20)
      Spacer()
    }
  }

  // MARK: - Card Skeleton

  private var cardSkeleton: some View {
    HStack(spacing: 16) {
      // 왼쪽 날짜 박스 skeleton
      SkeletonView(.round(cornerRadius: DDDSize.radiusLg))
        .frame(width: 60, height: 60)

      // 오른쪽 콘텐츠 skeleton
      VStack(alignment: .leading, spacing: 8) {
        // 제목 skeleton
        SkeletonView(.round(cornerRadius: DDDSize.radiusSm))
          .frame(height: 20)
          .frame(maxWidth: .infinity, alignment: .leading)

        // 설명 skeleton
        VStack(spacing: 4) {
          SkeletonView(.round(cornerRadius: DDDSize.radiusXs))
            .frame(height: 14)
            .frame(maxWidth: .infinity, alignment: .leading)

          SkeletonView(.round(cornerRadius: DDDSize.radiusXs))
            .frame(height: 14)
            .frame(width: 200, alignment: .leading)
        }
      }

      Spacer()
    }
    .padding(16)
    .background(
      RoundedRectangle(cornerRadius: DDDSize.radiusLg)
        .fill(Color.gray90)
    )
    .clipShape(RoundedRectangle(cornerRadius: DDDSize.radiusLg))
  }

  private var listSkeleton: some View {
    LazyVStack(spacing: 16) {
      ForEach(0..<7, id: \.self) { _ in
        cardSkeleton
      }
    }
  }
}

#Preview {
  ScheduleSkeletonView()
    .preferredColorScheme(.dark)
}
