//
//  CustomButton.swift
//  DDDDesignKit
//
//  Created by DDD on 11/2/24.
//

import SwiftUI

public struct CustomButton: View {
  private var action: () -> Void
  private var title: String
  private var config: DDDCustomButtonConfig
  private var isEnable: Bool = false

  public init(
    action: @escaping () -> Void,
    title: String,
    config: DDDCustomButtonConfig,
    isEnable: Bool = false
  ) {
    self.title = title
    self.config = config
    self.action = action
    self.isEnable = isEnable
  }

  public var body: some View {
    RoundedRectangle(cornerRadius: config.cornerRadius)
      .fill(isEnable ? config.enableBackgroundColor : config.disableBackgroundColor)
      .frame(height: config.frameHeight)
      .clipShape(RoundedRectangle(cornerRadius: config.cornerRadius))
      .overlay {
        Text(title)
          .pretendardFont(family: .SemiBold, size: 20)
          .foregroundColor(isEnable ? config.enableFontColor : config.disableFontColor)
      }
      .onTapGesture {
        action()
      }
      .disabled(!isEnable)
  }
}

// MARK: - 체이닝 설정
//
// 값 타입 사본을 돌려주므로 호출 순서에 영향받지 않는다.
// 기존 init 은 그대로 두어, 체이닝은 선택지로만 더한다.
public extension CustomButton {
  /// `action` 을 바꾼 사본을 돌려준다.
  func action(_ action: @escaping () -> Void) -> Self {
    var copy = self
    copy.action = action
    return copy
  }
  /// `title` 을 바꾼 사본을 돌려준다.
  func title(_ title: String) -> Self {
    var copy = self
    copy.title = title
    return copy
  }
  /// `config` 을 바꾼 사본을 돌려준다.
  func config(_ config: DDDCustomButtonConfig) -> Self {
    var copy = self
    copy.config = config
    return copy
  }
  /// `isEnable` 을 바꾼 사본을 돌려준다.
  func isEnable(_ isEnable: Bool) -> Self {
    var copy = self
    copy.isEnable = isEnable
    return copy
  }
}
