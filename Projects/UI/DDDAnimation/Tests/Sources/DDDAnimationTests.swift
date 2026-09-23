//
//  DDDAnimationTests.swift
//  DDDAnimationTests
//
//  Created by DDD on 9/1/26.
//

import Foundation
import SwiftUI
import Testing

@testable import DDDAnimation

@Suite("DDDAnimation")
struct DDDAnimationTests {
  @Test("모든 에셋이 모듈 번들에 실제로 존재한다", arguments: DDDAnimationAsset.allCases)
  func assetExistsInBundle(_ asset: DDDAnimationAsset) {
    let name = (asset.rawValue as NSString).deletingPathExtension
    let ext = (asset.rawValue as NSString).pathExtension
    #expect(Bundle.module.url(forResource: name, withExtension: ext) != nil)
  }

  @Test("화면 전환 애니메이션 토큰을 모두 제공한다")
  func screenTransitionAnimationsAreConfigured() {
    let animations = [
      AppAnimations.screenTransition,
      AppAnimations.modalTransition,
      AppAnimations.quickTransition,
    ]

    #expect(animations.count == 3)
    #expect(animations.allSatisfy { !String(reflecting: $0).isEmpty })
  }

  @Test("상호작용과 반복 애니메이션 토큰을 모두 제공한다")
  func interactionAnimationsAreConfigured() {
    let animations = [
      AppAnimations.buttonPress,
      AppAnimations.buttonHover,
      AppAnimations.loadingRotation,
      AppAnimations.pulseAnimation,
      AppAnimations.smoothEaseOut,
      AppAnimations.bounceEaseOut,
    ]

    #expect(animations.count == 6)
    #expect(animations.allSatisfy { !String(reflecting: $0).isEmpty })
  }

  @Test("편의 토큰이 대표 애니메이션과 동일한 설정을 노출한다")
  func convenienceAnimationsMatchCanonicalTokens() {
    #expect(String(reflecting: Animation.appDefault) == String(reflecting: AppAnimations.screenTransition))
    #expect(String(reflecting: Animation.appQuick) == String(reflecting: AppAnimations.quickTransition))
    #expect(String(reflecting: Animation.appButton) == String(reflecting: AppAnimations.buttonPress))
    #expect(String(reflecting: Animation.appModal) == String(reflecting: AppAnimations.modalTransition))
  }

  @Test("로딩 뷰가 정지 binding으로도 구성된다")
  func loadingViewAcceptsAnimationBinding() {
    let view = DDDAnimationView(.loading, isAnimating: .constant(false))

    #expect(!String(reflecting: view.body).isEmpty)
  }
}
