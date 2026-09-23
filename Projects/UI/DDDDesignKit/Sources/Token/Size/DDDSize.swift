//
//  DDDSize.swift
//  DDDDesignKit
//
//  Copyright © 2026 DDD. All rights reserved.
//

import CoreGraphics

/// 여백 토큰 (Semantic/spacing) — 4pt 그리드.
///
/// 값은 코드베이스에서 실제로 쓰이던 분포에서 뽑았다. padding 상위값이
/// 24(59회)·16(24)·20(19)·12·8·4·32 라 그리드가 이미 사실상 존재했다.
/// 10·14·6 처럼 그리드에서 벗어난 값은 토큰을 만들지 않았다 — 토큰에 맞추려면
/// 픽셀이 바뀌므로 디자인 확인이 필요한 건이다.
public enum DDDSize {
  /// 2pt
  public static let spacing2xs: CGFloat = 2
  /// 4pt
  public static let spacingXs: CGFloat = 4
  /// 8pt
  public static let spacingSm: CGFloat = 8
  /// 12pt
  public static let spacingMd: CGFloat = 12
  /// 16pt
  public static let spacingLg: CGFloat = 16
  /// 20pt
  public static let spacingXl: CGFloat = 20
  /// 24pt
  public static let spacing2xl: CGFloat = 24
  /// 32pt
  public static let spacing3xl: CGFloat = 32
  /// 48pt
  public static let spacing4xl: CGFloat = 48
}
