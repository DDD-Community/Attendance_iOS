//
//  StaffSkeletonView.swift
//  Presentation
//
//  Created by Wonji Suh  on 1/11/26.
//

import SwiftUI
import DesignSystem

public struct StaffSkeletonView: View {
  @State private var isShimmering = false

  public init() {}

  public var body: some View {
    ZStack {
      Color.basicBlack
        .ignoresSafeArea()

      ScrollView(.vertical) {
        VStack(alignment: .leading, spacing: 16) {
          headerSkeleton
          subtitleSkeleton
          largeCardSkeleton
          teamRowSkeleton
          listSkeleton
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 32)
      }
      .scrollIndicators(.hidden)
    }
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

  private var subtitleSkeleton: some View {
    RoundedRectangle(cornerRadius: 10)
      .fill(Color.gray.opacity(0.3))
      .frame(width: 180, height: 18)
      .overlay(shimmerEffect(delay: 0.15))
  }

  private var largeCardSkeleton: some View {
    RoundedRectangle(cornerRadius: 16)
      .fill(Color.gray.opacity(0.18))
      .frame(height: 96)
      .overlay(
        shimmerEffect(delay: 0.2)
          .clipShape(RoundedRectangle(cornerRadius: 16))
      )
  }

  private var teamRowSkeleton: some View {
    HStack(spacing: 12) {
      ForEach(0..<5, id: \.self) { index in
        RoundedRectangle(cornerRadius: 12)
          .fill(Color.gray.opacity(0.3))
          .frame(width: 60, height: 20)
          .overlay(shimmerEffect(delay: 0.3 + Double(index) * 0.1))
      }
    }
  }

  private var listSkeleton: some View {
    VStack(spacing: 14) {
      ForEach(0..<5, id: \.self) { index in
        RoundedRectangle(cornerRadius: 16)
          .fill(Color.gray.opacity(0.2))
          .frame(height: 76)
          .overlay(
            shimmerEffect(delay: 0.4 + Double(index) * 0.12)
              .clipShape(RoundedRectangle(cornerRadius: 16))
          )
      }
    }
  }

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
  StaffSkeletonView()
    .preferredColorScheme(.dark)
}
