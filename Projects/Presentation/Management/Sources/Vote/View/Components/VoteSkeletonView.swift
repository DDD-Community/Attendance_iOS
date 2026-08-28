//
//  VoteSkeletonView.swift
//  Management
//
//  Created by Roy on 6/11/26.
//

import SwiftUI

import DDDDesignKit

public struct VoteSkeletonView: View {
  @State private var isAnimating = false

  public init() {}

  public var body: some View {
    ZStack {
      Color.basicBlack

      VStack(alignment: .leading, spacing: 20) {
        headerSkeleton
        cardSkeleton
        buttonSkeleton
        Spacer()
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      .padding(.top, 20)
      .padding(.horizontal, 24)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .onAppear {
      withAnimation(.easeInOut(duration: 1.2).repeatCount(8, autoreverses: true)) {
        isAnimating = true
      }
    }
  }

  private var headerSkeleton: some View {
    VStack(alignment: .leading, spacing: 8) {
      RoundedRectangle(cornerRadius: 8)
        .fill(primaryFill)
        .frame(width: 120, height: 28)

      RoundedRectangle(cornerRadius: 6)
        .fill(secondaryFill)
        .frame(width: 240, height: 16)
    }
  }

  private var cardSkeleton: some View {
    VStack(spacing: 0) {
      row
      Rectangle().fill(secondaryFill).frame(height: 1)
      row
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 4)
    .frame(maxWidth: .infinity)
    .background {
      RoundedRectangle(cornerRadius: 12).fill(Color.gray90)
    }
  }

  private var row: some View {
    HStack {
      RoundedRectangle(cornerRadius: 6)
        .fill(secondaryFill)
        .frame(width: 55, height: 16)

      Spacer()

      RoundedRectangle(cornerRadius: 6)
        .fill(primaryFill)
        .frame(width: 120, height: 18)
    }
    .padding(.vertical, 14)
  }

  private var buttonSkeleton: some View {
    RoundedRectangle(cornerRadius: 10)
      .fill(primaryFill)
      .frame(height: 52)
      .frame(maxWidth: .infinity)
  }

  private var primaryFill: LinearGradient {
    let base = Color.gray90.opacity(isAnimating ? 0.35 : 0.7)
    let tint = Color.blue20.opacity(isAnimating ? 0.12 : 0.22)
    return LinearGradient(colors: [base, tint, base], startPoint: .topLeading, endPoint: .bottomTrailing)
  }

  private var secondaryFill: LinearGradient {
    let base = Color.gray90.opacity(isAnimating ? 0.25 : 0.55)
    let tint = Color.blue20.opacity(isAnimating ? 0.08 : 0.16)
    return LinearGradient(colors: [base, tint, base], startPoint: .topLeading, endPoint: .bottomTrailing)
  }
}

#Preview {
  VoteSkeletonView()
    .preferredColorScheme(.dark)
}
