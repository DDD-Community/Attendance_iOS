//
//  StepProgressBar.swift
//  DesignSystem
//
//  Created by Roy on 6/10/26.
//

import SwiftUI

/// 투표 1·2단계 상단 스텝 진행바.
/// `currentStep` 이 바뀌면 채움 바 너비가 애니메이션으로 이동한다.
public struct StepProgressBar: View {
  private let currentStep: Int
  private let totalSteps: Int
  private let animation: Animation

  public init(
    currentStep: Int,
    totalSteps: Int,
    animation: Animation = .easeInOut(duration: 0.35)
  ) {
    self.currentStep = max(0, min(currentStep, totalSteps))
    self.totalSteps = max(1, totalSteps)
    self.animation = animation
  }

  private var progress: CGFloat {
    CGFloat(currentStep) / CGFloat(totalSteps)
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("STEP \(currentStep) / \(totalSteps)")
        .pretendardFont(family: .Bold, size: 14)
        .foregroundStyle(Color.statusFocus)

      GeometryReader { proxy in
        Capsule()
          .fill(Color.borderDisabled)
          .overlay(alignment: .leading) {
            Capsule()
              .fill(Color.statusFocus)
              .frame(width: proxy.size.width * progress)
          }
      }
      .frame(height: 6)
      .animation(animation, value: progress)
    }
  }
}

#Preview {
  struct PreviewContainer: View {
    @State private var step = 1

    var body: some View {
      VStack(spacing: 40) {
        StepProgressBar(currentStep: step, totalSteps: 2)
        Button("다음 단계") { step = step == 1 ? 2 : 1 }
          .foregroundStyle(Color.statusFocus)
      }
      .padding(24)
      .frame(maxWidth: 375)
      .background(Color.backGroundPrimary)
    }
  }
  return PreviewContainer()
}
