//
//  ProfileSkeletonView.swift
//  Profile
//
//  Created by Wonji Suh on 1/5/26.
//

import SwiftUI
import DesignSystem

public struct ProfileSkeletonView: View {
  @State private var isAnimating = false

  public init() {}

  public var body: some View {
    VStack {
      Spacer()
        .frame(height: 17)

      skeletonProfileCard()

      Spacer()
        .frame(height: 36)

      skeletonLogoutButtons()

      Spacer()
        .frame(height: 12)

      skeletonAppInfo()

      Spacer()
        .frame(height: 40)
    }
    .padding(.horizontal, 24)
    .onAppear {
      withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
        isAnimating = true
      }
    }
  }
}

extension ProfileSkeletonView {
  @ViewBuilder
  private func skeletonProfileCard() -> some View {
    VStack(alignment: .leading, spacing: .zero) {
      // 상단 멤버 태그 & 기수 변경 버튼
      HStack {
        skeletonRoundedButton(width: 60, height: 30)

        Spacer()

        skeletonRoundedButton(width: 100, height: 35)
      }

      Spacer()
        .frame(height: 20)

      // 사용자 이름
      skeletonText(width: 120, height: 24)

      Spacer()
        .frame(height: 40)

      // 직군, 팀, 기수 정보
      VStack(alignment: .leading, spacing: 20) {
        skeletonInfoRow()
        skeletonInfoRow()
        skeletonInfoRow()
      }

      Spacer()
        .frame(height: 40)

      // 하단 Dynamic Developer Designers
      HStack {
        Spacer()
        skeletonText(width: 180, height: 16)
        Spacer()
      }
    }
    .padding(24)
    .background(
      RoundedRectangle(cornerRadius: 20)
        .fill(.gray80.opacity(0.5))
    )
    .frame(height: UIScreen.screenHeight * 0.7)
  }

  @ViewBuilder
  private func skeletonInfoRow() -> some View {
    VStack(alignment: .leading, spacing: 2) {
      skeletonText(width: 60, height: 14)
      skeletonText(width: 100, height: 20)
    }
  }

  @ViewBuilder
  private func skeletonLogoutButtons() -> some View {
    HStack {
      skeletonText(width: 60, height: 16)

      Spacer()
        .frame(width: 64)

      skeletonText(width: 60, height: 16)
    }
  }

  @ViewBuilder
  private func skeletonAppInfo() -> some View {
    VStack(spacing: 4) {
      skeletonText(width: 80, height: 14)
      skeletonText(width: 120, height: 14)
    }
  }

  @ViewBuilder
  private func skeletonText(width: CGFloat, height: CGFloat) -> some View {
    RoundedRectangle(cornerRadius: 4)
      .fill(.gray90.opacity(isAnimating ? 0.4 : 0.8))
      .frame(width: width, height: height)
  }

  @ViewBuilder
  private func skeletonRoundedButton(width: CGFloat, height: CGFloat) -> some View {
    RoundedRectangle(cornerRadius: 20)
      .fill(.gray90.opacity(isAnimating ? 0.4 : 0.8))
      .frame(width: width, height: height)
  }
}

#Preview {
  ProfileSkeletonView()
    .background(Color.basicBlack)
}