//
//  StepNavigationBar.swift
//  DDDDesignKit
//
//  Created by DDD on 11/3/24.
//

import SwiftUI

public struct StepNavigationBar: View {
  private var activeStep = 1
  private var buttonAction: () -> Void = {}

  public init() {}
  
  public var body: some View {
    HStack {
      Button(action: buttonAction) {
        Image(asset: .backButton)
          .resizable()
          .scaledToFit()
          .frame(width: 12, height: 20)
          .foregroundStyle(.gray400)
          .frame(width: 44, height: 44)
          .contentShape(Rectangle())
      }
      .buttonStyle(.plain)
      .accessibilityLabel("뒤로가기")
      
      Spacer()
      
      HStack(alignment: .center, spacing: 2) {
        ForEach(1...3, id: \.self) { step in
          Rectangle()
            .foregroundColor(.clear)
            .frame(maxWidth: 78, minHeight: 3, maxHeight: 3)
            .background(step <= activeStep ? Color.grayWhite : Color.gray80)
            .clipShape(Capsule())
        }
      }
      
      Spacer()
    }
    .padding(.horizontal, 16)
  }
}

// MARK: - 체이닝 설정
//
// 값 타입 사본을 돌려주므로 호출 순서에 영향받지 않는다.
public extension StepNavigationBar {
  /// `activeStep` 을 바꾼 사본을 돌려준다.
  func activeStep(_ activeStep: Int) -> Self {
    var copy = self
    copy.activeStep = activeStep
    return copy
  }
  /// `buttonAction` 을 바꾼 사본을 돌려준다.
  func buttonAction(_ buttonAction: @escaping () -> Void) -> Self {
    var copy = self
    copy.buttonAction = buttonAction
    return copy
  }
}
