//
//  SkeletonShape.swift
//  DDDDesignKit
//
//  Copyright © 2026 DDD. All rights reserved.
//

import SwiftUI

/// 스켈레톤 자리표시자의 외곽 형태.
public enum SkeletonShape: Shape {
  case rect
  case round(cornerRadius: CGFloat = DDDSize.radiusMd)
  case circle

  public func path(in rect: CGRect) -> Path {
    switch self {
    case .rect:
      return Rectangle().path(in: rect)

    case let .round(cornerRadius):
      return RoundedRectangle(cornerRadius: cornerRadius, style: .circular).path(in: rect)

    case .circle:
      return Circle().path(in: rect)
    }
  }
}
