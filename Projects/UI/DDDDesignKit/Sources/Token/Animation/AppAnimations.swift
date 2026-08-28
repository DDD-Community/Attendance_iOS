//
//  AppAnimations.swift
//  DDDDesignKit
//
//  Created by Wonji Suh  on 1/15/26.
//

import SwiftUI

public struct AppAnimations {
  // MARK: - Screen Transitions
  public static let screenTransition = Animation.spring(
    response: 0.52,
    dampingFraction: 0.94,
    blendDuration: 0.14
  )

  public static let modalTransition = Animation.spring(
    response: 0.42,
    dampingFraction: 0.88
  )

  public static let quickTransition = Animation.spring(
    response: 0.32,
    dampingFraction: 0.92
  )

  // MARK: - Button Animations
  public static let buttonPress = Animation.spring(
    response: 0.25,
    dampingFraction: 0.8
  )

  public static let buttonHover = Animation.spring(
    response: 0.18,
    dampingFraction: 0.75
  )

  // MARK: - Loading Animations
  public static let loadingRotation = Animation.linear(duration: 1.0).repeatForever(autoreverses: false)

  public static let pulseAnimation = Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true)

  // MARK: - Custom Easing
  public static let smoothEaseOut = Animation.timingCurve(0.25, 0.46, 0.45, 0.94)

  public static let bounceEaseOut = Animation.timingCurve(0.175, 0.885, 0.32, 1.275)
}

// MARK: - Convenience Extensions
public extension Animation {
  static var appDefault: Animation {
    AppAnimations.screenTransition
  }

  static var appQuick: Animation {
    AppAnimations.quickTransition
  }

  static var appButton: Animation {
    AppAnimations.buttonPress
  }

  static var appModal: Animation {
    AppAnimations.modalTransition
  }
}