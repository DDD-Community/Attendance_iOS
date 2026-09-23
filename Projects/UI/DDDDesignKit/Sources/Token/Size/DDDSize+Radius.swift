//
//  DDDSize+Radius.swift
//  DDDDesignKit
//
//  Copyright © 2026 DDD. All rights reserved.
//

import CoreGraphics

/// 모서리 반경 토큰 (Semantic/radius).
///
/// cornerRadius 사용 분포 12(23회)·20(19)·16(19)·6(15)·10(12)·8·4 기준.
public extension DDDSize {
  /// 4pt
  static let radiusXs: CGFloat = 4
  /// 6pt
  static let radiusSm: CGFloat = 6
  /// 8pt
  static let radiusMd: CGFloat = 8
  /// 12pt
  static let radiusLg: CGFloat = 12
  /// 16pt
  static let radiusXl: CGFloat = 16
  /// 20pt
  static let radius2xl: CGFloat = 20
  /// 999pt — 캡슐. 뷰 높이와 무관하게 항상 완전 라운드.
  static let radiusFull: CGFloat = 999
}
