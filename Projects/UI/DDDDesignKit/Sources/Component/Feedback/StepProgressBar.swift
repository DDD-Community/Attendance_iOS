//
//  StepProgressBar.swift
//  DDDDesignKit
//
//  Created by DDD on 6/10/26.
//

import SwiftUI

/// 투표 1·2단계 상단 스텝 진행바.
/// `currentStep` 이 바뀌면 채움 바 너비가 애니메이션으로 이동한다.
public struct StepProgressBar: View {
  private var currentStep: Int
  private var totalSteps: Int
  private var animation: Animation

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

// MARK: - 체이닝 설정
//
// 값 타입 사본을 돌려주므로 호출 순서에 영향받지 않는다.
// 기존 init 은 그대로 두어, 체이닝은 선택지로만 더한다.
public extension StepProgressBar {
  /// `currentStep` 을 바꾼 사본을 돌려준다.
  func currentStep(_ currentStep: Int) -> Self {
    var copy = self
    copy.currentStep = currentStep
    return copy
  }
  /// `totalSteps` 을 바꾼 사본을 돌려준다.
  func totalSteps(_ totalSteps: Int) -> Self {
    var copy = self
    copy.totalSteps = totalSteps
    return copy
  }
  /// `animation` 을 바꾼 사본을 돌려준다.
  func animation(_ animation: Animation) -> Self {
    var copy = self
    copy.animation = animation
    return copy
  }
}
