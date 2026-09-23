//
//  TooltipShape.swift
//  DDDDesignKit
//
//  Created by DDD on 7/14/24.
//

import SwiftUI

public struct TooltipShape: View {
  private var tooltipText: String
  
  public init(tooltipText: String) {
    self.tooltipText = tooltipText
  }
  
  public var body: some View {
    VStack {
      ZStack {
        TriangleDownShape()
          .fill(Color.gray800)
          .padding(.leading, 5)
          .padding(.top, 40)
        
        TooltipBody(text: tooltipText)
      }
      .frame(width: 202, height: 50)
    }
  }
}

// MARK: - 체이닝 설정
//
// 값 타입 사본을 돌려주므로 호출 순서에 영향받지 않는다.
// 기존 init 은 그대로 두어, 체이닝은 선택지로만 더한다.
public extension TooltipShape {
  /// `tooltipText` 을 바꾼 사본을 돌려준다.
  func tooltipText(_ tooltipText: String) -> Self {
    var copy = self
    copy.tooltipText = tooltipText
    return copy
  }
}
