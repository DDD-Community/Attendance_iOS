//
//  StaffSkeletonView.swift
//  Presentation
//
//  Created by Wonji Suh  on 1/11/26.
//

import SwiftUI
import DesignSystem

public struct StaffSkeletonView: View {
  @State private var isAnimating = false

  public init() {}

  public var body: some View {
    ZStack {
      Color.basicBlack
        .ignoresSafeArea()

      ScrollView(.vertical) {
        VStack(alignment: .leading, spacing: 14) {
          headerSkeleton
          subtitleSkeleton
          largeCardSkeleton
          teamRowSkeleton
          listSkeleton
        }
        .padding(.horizontal, 24)
        .padding(.top, 10)
        .padding(.bottom, 28)
      }
      .scrollIndicators(.hidden)
    }
    .onAppear {
      withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
        isAnimating = true
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

  private var subtitleSkeleton: some View {
    RoundedRectangle(cornerRadius: 10)
      .fill(primarySkeletonFill)
      .frame(width: 180, height: 18)
  }

  private var largeCardSkeleton: some View {
    RoundedRectangle(cornerRadius: 16)
      .fill(secondarySkeletonFill)
      .frame(height: 96)
  }

  private var teamRowSkeleton: some View {
    HStack(spacing: 12) {
      ForEach(0..<5, id: \.self) { index in
        RoundedRectangle(cornerRadius: 12)
          .fill(primarySkeletonFill)
          .frame(width: 60, height: 20)
      }
    }
    .padding(.top, 2)
  }

  private var listSkeleton: some View {
    VStack(spacing: 12) {
      ForEach(0..<5, id: \.self) { index in
        RoundedRectangle(cornerRadius: 16)
          .fill(secondarySkeletonFill)
          .frame(height: 76)
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
  StaffSkeletonView()
    .preferredColorScheme(.dark)
}
