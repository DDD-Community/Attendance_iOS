//
//  DDDSize+Icon.swift
//  DDDDesignKit
//
//  Copyright © 2026 DDD. All rights reserved.
//

import CoreGraphics

/// 아이콘 정사각 크기 토큰 (Semantic/icon).
///
/// 정사각 frame 사용 분포 20(10회)·36(5)·24(5)·28(3)·44 기준.
public extension DDDSize {
  /// 16pt
  static let iconXs: CGFloat = 16
  /// 20pt
  static let iconSm: CGFloat = 20
  /// 24pt
  static let iconMd: CGFloat = 24
  /// 28pt
  static let iconLg: CGFloat = 28
  /// 36pt
  static let iconXl: CGFloat = 36
  /// 44pt — 최소 터치 타깃(HIG).
  static let icon2xl: CGFloat = 44
}
