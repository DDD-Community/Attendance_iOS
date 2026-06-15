//
//  FlowLayout.swift
//  DesignSystem
//
//  Created by Roy on 6/10/26.
//

import SwiftUI

/// 가로 폭이 넘치면 다음 줄로 흘려보내는(wrap) 레이아웃.
/// 칩 개수가 서버 데이터에 따라 가변이므로 줄바꿈을 코드가 자동 처리한다.
public struct FlowLayout: Layout {
  public var horizontalSpacing: CGFloat
  public var verticalSpacing: CGFloat

  public init(horizontalSpacing: CGFloat = 8, verticalSpacing: CGFloat = 8) {
    self.horizontalSpacing = horizontalSpacing
    self.verticalSpacing = verticalSpacing
  }

  public func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache _: inout Void
  ) -> CGSize {
    let maxWidth = proposal.width ?? .infinity
    let rows = arrange(subviews: subviews, maxWidth: maxWidth)
    let width = rows.map(\.width).max() ?? 0
    let height = rows.reduce(into: CGFloat.zero) { $0 += $1.height }
      + verticalSpacing * CGFloat(max(0, rows.count - 1))
    return CGSize(width: min(width, maxWidth), height: height)
  }

  public func placeSubviews(
    in bounds: CGRect,
    proposal _: ProposedViewSize,
    subviews: Subviews,
    cache _: inout Void
  ) {
    let rows = arrange(subviews: subviews, maxWidth: bounds.width)
    var y = bounds.minY
    for row in rows {
      var x = bounds.minX
      for index in row.indices {
        let size = subviews[index].sizeThatFits(.unspecified)
        subviews[index].place(
          at: CGPoint(x: x, y: y),
          anchor: .topLeading,
          proposal: ProposedViewSize(size)
        )
        x += size.width + horizontalSpacing
      }
      y += row.height + verticalSpacing
    }
  }

  private struct Row {
    var indices: [Int] = []
    var width: CGFloat = 0
    var height: CGFloat = 0
  }

  private func arrange(subviews: Subviews, maxWidth: CGFloat) -> [Row] {
    var rows: [Row] = []
    var current = Row()

    for index in subviews.indices {
      let size = subviews[index].sizeThatFits(.unspecified)
      let projectedWidth = current.indices.isEmpty
        ? size.width
        : current.width + horizontalSpacing + size.width

      if !current.indices.isEmpty, projectedWidth > maxWidth {
        rows.append(current)
        current = Row()
      }

      current.width = current.indices.isEmpty
        ? size.width
        : current.width + horizontalSpacing + size.width
      current.height = max(current.height, size.height)
      current.indices.append(index)
    }

    if !current.indices.isEmpty {
      rows.append(current)
    }
    return rows
  }
}
